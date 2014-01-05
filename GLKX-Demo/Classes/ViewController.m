#import "ViewController.h"

#import "GLKX_Library.h"

#import "GLK2Texture.h"

#import <AVFoundation/AVFoundation.h>
#import "GLK2Texture+CoreVideo.h"

#import "GLK2Texture+CoreGraphics.h"

#import "CommonGLEngineCode.h"

@interface PlayableVideo : NSObject

@property(nonatomic,retain) GLK2Texture* texture;

@property(nonatomic) BOOL isVideoReadyToRead;
@property(nonatomic,retain) AVAssetReaderTrackOutput *readerVideoTrackOutput;
@property(nonatomic,retain) AVAssetReader* reader;

@property(nonatomic) uint64_t lastReadVideoFrameTimeMillis;

@property(nonatomic,retain) NSString* localPath;

@property(nonatomic, retain) NSURL* URLToLocalFile;

@end
@implementation PlayableVideo

@end


@interface ViewController ()
{
	#pragma mark - Apple efficient video textures
	CVOpenGLESTextureCacheRef coreVideoTextureCache;
}

#pragma mark - Apple efficient video textures
@property(nonatomic,retain) GLK2Texture* textureVideoLuminance, * textureVideoChroma;
@property(nonatomic,retain) GLK2DrawCall* drawCallThatRendersVideoTextures;

@property(nonatomic,retain) PlayableVideo* v;

@end

@implementation ViewController
{
	GLKMatrix4 projectionMatrix;
	
	CVOpenGLESTextureRef appleCreatedTexture1, appleCreatedTexture2; // Apple's appallingly bad code forces you to cache AND DESTROY these every "pseudo-frame"
}

- (void)dealloc
{
    [super dealloc];
}

#define WORKING_VIDEO_FROM_FILE 0
#if WORKING_VIDEO_FROM_FILE
- (void)startProcessingVideo:(PlayableVideo*) video
{
    NSDictionary *inputOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *inputAsset = [[AVURLAsset alloc] initWithURL:video.URLToLocalFile options:inputOptions];
	
    [inputAsset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:@"tracks"] completionHandler: ^{
        NSError *error = nil;
        AVKeyValueStatus tracksStatus = [inputAsset statusOfValueForKey:@"tracks" error:&error];
        if (!tracksStatus == AVKeyValueStatusLoaded)
        {
			NSLog(@"Error = %@", error);
            return;
        }
        video.reader = [AVAssetReader assetReaderWithAsset:inputAsset error:&error];
		
        NSMutableDictionary *outputSettings = [NSMutableDictionary dictionary];
        [outputSettings setObject: [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]  forKey: (NSString*)kCVPixelBufferPixelFormatTypeKey];
        // Maybe set alwaysCopiesSampleData to NO on iOS 5.0 for faster video decoding
		NSArray* videoTracks = [inputAsset tracksWithMediaType:AVMediaTypeVideo];
        video.readerVideoTrackOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:[videoTracks firstObject] outputSettings:outputSettings];
        [video.reader addOutput:video.readerVideoTrackOutput];
		
#define PLAY_AUDIO 0
#if PLAY_AUDIO
        NSArray *audioTracks = [inputAsset tracksWithMediaType:AVMediaTypeAudio];
        BOOL shouldRecordAudioTrack = (([audioTracks count] > 0) && (self.audioEncodingTarget != nil) );
        AVAssetReaderTrackOutput *readerAudioTrackOutput = nil;
		
        if (shouldRecordAudioTrack)
        {
            audioEncodingIsFinished = NO;
			
            // This might need to be extended to handle movies with more than one audio track
            AVAssetTrack* audioTrack = [audioTracks objectAtIndex:0];
            readerAudioTrackOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:nil];
            [reader addOutput:readerAudioTrackOutput];
        }
#endif
		
        if ([video.reader startReading] == NO)
        {
            NSLog(@"Error reading from file at URL: %@", video.URLToLocalFile);
            return;
        }
		
		video.isVideoReadyToRead = TRUE;
    }];
}

- (void)readNextVideo:(PlayableVideo*) video frameFromOutput:(AVAssetReaderTrackOutput *)readerVideoTrackOutput
{
    if (video.reader.status == AVAssetReaderStatusReading)
    {
        CMSampleBufferRef sampleBufferRef = [readerVideoTrackOutput copyNextSampleBuffer];
		
		switch( video.reader.status )
		{
			case AVAssetReaderStatusCancelled:
				NSLog(@"Cancelled");
				break;
			case AVAssetReaderStatusCompleted:
			{
				NSLog(@"Completed");
				
				double delayInSeconds = 0.5;
				dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
				dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
					NSLog(@"Re-starting");
					[self startProcessingVideo:video];
				});
			}break;
			case AVAssetReaderStatusFailed:
				NSLog(@"Failed");
				break;
			case AVAssetReaderStatusReading:
				//DEBUG:	NSLog(@"Reading");
				break;
			case AVAssetReaderStatusUnknown:
				NSLog(@"Unknown");
				break;
		}
        if (sampleBufferRef)
        {
			//DEBUG: NSLog(@"Received a frame");
			[self processMovieFrame:sampleBufferRef fromVideo:video];
			
            CMSampleBufferInvalidate(sampleBufferRef);
            CFRelease(sampleBufferRef);
        }
        else
        {
			//ADAM: might be no more data for current time, wait for more frames
			
            //videoEncodingIsFinished = YES;
            //[self endProcessing];
        }
    }
}

- (void)processMovieFrame:(CMSampleBufferRef)movieSampleBuffer fromVideo:(PlayableVideo*) video
{
    CMTime currentSampleTime = CMSampleBufferGetOutputPresentationTimeStamp(movieSampleBuffer);
	//DEBUG: NSLog(@"   Using video sample at time = %.4f", CMTimeGetSeconds(currentSampleTime));
	
    CVImageBufferRef movieFrame = CMSampleBufferGetImageBuffer(movieSampleBuffer);
	
    int bufferHeight = CVPixelBufferGetHeight(movieFrame);
    int bufferWidth = CVPixelBufferGetWidth(movieFrame);
	
	// Upload to texture
	CVPixelBufferLockBaseAddress(movieFrame, 0);
	
	//NSLog(@"Replacing texture %i with movie frame", self.textureForVideoOutput.glName);
	glBindTexture(GL_TEXTURE_2D, video.texture.glName);
	// Using BGRA extension to pull in video frame data directly
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, bufferWidth, bufferHeight, 0, GL_BGRA, GL_UNSIGNED_BYTE, CVPixelBufferGetBaseAddress(movieFrame));
	
	CVPixelBufferUnlockBaseAddress(movieFrame, 0);
}

#else

/** Apple's code from: https://developer.apple.com/library/ios/samplecode/GLCameraRipple/Listings/GLCameraRipple_RippleViewController_m.html#//apple_ref/doc/uid/DTS40011222-GLCameraRipple_RippleViewController_m-DontLinkElementID_8
 */
- (AVCaptureSession*) setupAVCapture
{
	AVCaptureSession* session;
	
    //-- Create CVOpenGLESTextureCacheRef for optimal CVImageBufferRef to GLES texture conversion.
/*#if COREVIDEO_USE_EAGLCONTEXT_CLASS_IN_API
    CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, self.localContext, NULL, &coreVideoTextureCache);
#else*/
    CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, (__bridge void *)self.localContext, NULL, &coreVideoTextureCache);
//#endif
    if (err)
    {
        NSLog(@"Error at CVOpenGLESTextureCacheCreate %d", err);
        return  nil;
    }
    //-- Setup Capture Session
    session = [[[AVCaptureSession alloc] init] autorelease];
	[session retain];
    [session beginConfiguration];
	
    //-- Set preset session size.
    [session setSessionPreset:AVCaptureSessionPreset640x480];
	
    //-- Creata a video device and input from that Device.  Add the input to the capture session.
    AVCaptureDevice * videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if(videoDevice == nil)
        assert(0);
	
    //-- Add the device to the session.
    NSError *error;        
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    if(error)
        assert(0);
	
    [session addInput:input];

    //-- Create the output for the capture session.
	AVCaptureVideoDataOutput * dataOutput = [[AVCaptureVideoDataOutput alloc] init];
	[dataOutput setAlwaysDiscardsLateVideoFrames:YES]; // Probably want to set this to NO when recording
	
    //-- Set to YUV420.
	[dataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange] 
	                                                         forKey:(id)kCVPixelBufferPixelFormatTypeKey]]; // Necessary for manual preview
	
    // Set dispatch to be on the main thread so OpenGL can do things with the data
	[dataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];        
	
    [session addOutput:dataOutput];
	[session commitConfiguration];
	
    [session startRunning];
	
	return session;
}

/** Apple's code from: https://developer.apple.com/library/ios/samplecode/GLCameraRipple/Listings/GLCameraRipple_RippleViewController_m.html#//apple_ref/doc/uid/DTS40011222-GLCameraRipple_RippleViewController_m-DontLinkElementID_8
 */
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    CVReturn err;
    CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    GLsizei width = (GLsizei)CVPixelBufferGetWidth(pixelBuffer);
    GLsizei height = (GLsizei)CVPixelBufferGetHeight(pixelBuffer);
	if (!coreVideoTextureCache)
    {
        NSLog(@"No video texture cache");
        return;
    }
		
    {
		if( appleCreatedTexture1 != NULL )
		CFRelease( appleCreatedTexture1 ); // Apple requires this
		if( appleCreatedTexture2 != NULL )
		CFRelease( appleCreatedTexture2 ); // Apple requires this

		// Periodic texture cache flush every frame
		CVOpenGLESTextureCacheFlush(coreVideoTextureCache, 0); // Apple requires this
	}

    // CVOpenGLESTextureCacheCreateTextureFromImage will create GLES texture
    // optimally from CVImageBufferRef.

    // Y-plane
    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, 
                                                       coreVideoTextureCache,
                                                       pixelBuffer,
                                                       NULL,
                                                       GL_TEXTURE_2D,
                                                       GL_RED_EXT,
                                                       width,
                                                       height,
                                                       GL_RED_EXT,
                                                       GL_UNSIGNED_BYTE,
                                                       0,
                                                       &appleCreatedTexture1);
	
    if (err) 
    {
        NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
    }   
	
    // UV-plane
    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, 
                                                       coreVideoTextureCache,
                                                       pixelBuffer,
                                                       NULL,
                                                       GL_TEXTURE_2D,
                                                       GL_RG_EXT,
                                                       width/2,
                                                       height/2,
                                                       GL_RG_EXT,
                                                       GL_UNSIGNED_BYTE,
                                                       1,
                                                       &appleCreatedTexture2);
	
    if (err) 
    {
        NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
    }
	
	NSAssert( CVOpenGLESTextureGetTarget( appleCreatedTexture1 ) == GL_TEXTURE_2D, @"Argh" );
	NSAssert( CVOpenGLESTextureGetTarget( appleCreatedTexture2 ) == GL_TEXTURE_2D, @"Argh" );
	
	NSAssert(self.drawCallThatRendersVideoTextures != nil, @"Need to know which drawcall to update with the Apple-repeatedly-generated-then-destroyed texture");
	
	//DEBUG: NSLog(@"About to store textures (%i) and (%i)", CVOpenGLESTextureGetName(appleCreatedTexture1), CVOpenGLESTextureGetName(appleCreatedTexture2) );
	
	if( self.textureVideoLuminance == nil
	|| appleCreatedTexture1 == NULL
	|| self.textureVideoLuminance.glName != CVOpenGLESTextureGetName(appleCreatedTexture1) )
	{
		self.textureVideoLuminance = [GLK2Texture texturePreCreatedByApplesCoreVideo:appleCreatedTexture1];
		self.textureVideoLuminance.willDeleteOnDealloc = FALSE; // FIXME: Apple doesn't tell us when it's safe to glDeleteTextures ??? BUT: it's asynch! I suspect that the CVOpenGLESTextureCacheRef is meant to help with this - but it's been TWO YEARS! And Apple still can't be botherd to document their API
	}
	
	[self.drawCallThatRendersVideoTextures setTexture:self.textureVideoLuminance forSampler:[self.drawCallThatRendersVideoTextures.shaderProgram uniformNamed:@"s_texture1"]];
	
	/**
	 This is odd...
	 
	 Apple's code silently crashes with a black texture if you don't explicigly WRAP s,t.
	 
	 I don't know why we must 'wrap' a video texture that's mapped to 0..1 in the first place ???
	 */
	glActiveTexture(GL_TEXTURE0);
	glBindTexture( CVOpenGLESTextureGetTarget(appleCreatedTexture1), CVOpenGLESTextureGetName(appleCreatedTexture1));
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

	
	if( self.textureVideoChroma == nil
	|| appleCreatedTexture2 == NULL
	|| self.textureVideoChroma.glName != CVOpenGLESTextureGetName(appleCreatedTexture2) )
	{
		self.textureVideoChroma = [GLK2Texture texturePreCreatedByApplesCoreVideo:appleCreatedTexture2];
		self.textureVideoChroma.willDeleteOnDealloc = FALSE; // FIXME: Apple doesn't tell us when it's safe to glDeleteTextures ??? BUT: it's asynch! I suspect that the CVOpenGLESTextureCacheRef is meant to help with this - but it's been TWO YEARS! And Apple still can't be botherd to document their API
	}
	
	[self.drawCallThatRendersVideoTextures setTexture:self.textureVideoChroma forSampler:[self.drawCallThatRendersVideoTextures.shaderProgram uniformNamed:@"s_texture2"]];
	
	/**
	 This is odd...
	 
	 Apple's code silently crashes with a black texture if you don't explicigly WRAP s,t.
	 
	 I don't know why we must 'wrap' a video texture that's mapped to 0..1 in the first place ???
	 */
	glActiveTexture(GL_TEXTURE1);
	glBindTexture( CVOpenGLESTextureGetTarget(appleCreatedTexture2), CVOpenGLESTextureGetName(appleCreatedTexture2));
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

	//DEBUG: NSLog(@"Converted frame to texture (%i) and (%i)", self.textureVideoLuminance.glName, self.textureVideoChroma.glName );
}
#endif

-(NSMutableArray*) createAllDrawCalls
{	
	/** All the local setup for the ViewController */
	NSMutableArray* result = [NSMutableArray array];
	
	/** -- Draw Call 1:
	 
	 clear the background
	 */
	GLK2DrawCall* simpleClearingCall = [[GLK2DrawCall new] autorelease];
	simpleClearingCall.shouldClearColorBit = TRUE;
	[simpleClearingCall setClearColourRed:0.5 green:0 blue:0 alpha:1];
	[result addObject: simpleClearingCall];
	
#define TEST_ONE_TRIANGLE_AT_ORIGIN 1
#define TEST_ONE_CUBE_AT_ORIGIN 1
	
#if TEST_ONE_TRIANGLE_AT_ORIGIN
	GLK2DrawCall* dcTri = [CommonGLEngineCode drawCallWithUnitTriangleAtOriginUsingShaders:
						   [GLK2ShaderProgram shaderProgramFromVertexFilename:@"VertexProjectedWithTexture" fragmentFilename:@"FragmentWithTexture"]];
	GLK2Uniform* samplerTexture1 = [dcTri.shaderProgram uniformNamed:@"s_texture1"];
	GLK2Texture* texture = [GLK2Texture textureNamed:@"tex2"];
	[dcTri setTexture:texture forSampler:samplerTexture1];
		
	[result addObject:dcTri];
#endif
	
#if TEST_ONE_CUBE_AT_ORIGIN
	GLK2DrawCall* dcCube = [CommonGLEngineCode drawCallWithUnitCubeAtOriginUsingShaders:
#if WORKING_VIDEO_FROM_FILE
						   [GLK2ShaderProgram shaderProgramFromVertexFilename:@"VertexProjectedWithTexture" fragmentFilename:@"FragmentWithTexture"]];
#else
							[GLK2ShaderProgram shaderProgramFromVertexFilename:@"VertexProjectedWithTexture" fragmentFilename:@"FragmentVideoPairTexture"]];
#endif
	/*GLK2Uniform* samplerTexture1 = [dcCube.shaderProgram uniformNamed:@"s_texture1"];
	GLK2Texture* texture = [GLK2Texture textureNamed:@"tex2"];
	[dcCube setTexture:texture forSampler:samplerTexture1];*/
	[result addObject:dcCube];
	
#if WORKING_VIDEO_FROM_FILE
	self.v = [[PlayableVideo new] autorelease];
	self.v.texture = [GLK2Texture textureNamed:@"black-with-white-stripe"]; // placeholder that will get overwritten quickly
	
/*	NSString* documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, TRUE) objectAtIndex:0];
	NSString* path = [documentsDirectory stringByAppendingPathComponent:@"split-mesh-lat-lines.mov"];
	NSURL* outputFile = [NSURL fileURLWithPath:path];
	self.v.URLToLocalFile = outputFile;*/
	self.v.URLToLocalFile = [[NSBundle mainBundle] URLForResource:@"split-mesh-lat-lines" withExtension:@"mov"];
	
	[self startProcessingVideo:self.v];
#else
	[self setupAVCapture];
#endif
#endif
	
	self.drawCallThatRendersVideoTextures = dcCube;
	
	return result;
}

-(void)willRenderDrawCallUsingVAOShaderProgramAndDefaultUniforms:(GLK2DrawCall *)drawCall
{
	/*************** Rotate the entire world, for Shaders that support it *******************/
	GLK2Uniform* uniProjectionMatrix = [drawCall.shaderProgram uniformNamed:@"projectionMatrix"];
	if( uniProjectionMatrix != nil )
	{
		/** Generate a smoothly increasing value using GLKit's built-in frame-count and frame-timers */
		long slowdownFactor = 5; // scales the counter down before we modulus, so rotation is slower
		long framesOutOfFramesPerSecond = self.framesDisplayed % (self.framesPerSecond * slowdownFactor);
		float radians = framesOutOfFramesPerSecond / (float) (self.framesPerSecond * slowdownFactor);
		
		// rotate it
		GLKMatrix4 rotatingProjectionMatrix = GLKMatrix4MakeRotation( radians * 2.0 * M_PI, 1.0, 1.0, 1.0 );
		
		[drawCall.shaderProgram setValue:&rotatingProjectionMatrix forUniform:uniProjectionMatrix];
	}
	
#if WORKING_VIDEO_FROM_FILE
	if( drawCall == self.drawCallThatRendersVideoTextures )
	{
		PlayableVideo* video = self.v;
			if( video != nil && video.isVideoReadyToRead )
			{
				uint64_t minMillisBetweenVideoFrames = 50;
				uint64_t timeNowMillis = timeAbsoluteMilliseconds();
				if( timeNowMillis - video.lastReadVideoFrameTimeMillis > minMillisBetweenVideoFrames)
				{
					//DEBUG: NSLog(@"Received a frame, and its been long enough to process a new one");
					if (video.reader.status == AVAssetReaderStatusReading)
					{
						[self readNextVideo:video frameFromOutput:video.readerVideoTrackOutput];
						
#if PLAY_AUDIO
						if ( (shouldRecordAudioTrack) && (!audioEncodingIsFinished) )
						{
							[self readNextAudioSampleFromOutput:readerAudioTrackOutput];
						}
#endif
						
					}
					
					if (video.reader.status == AVAssetWriterStatusCompleted) {
					}
					video.lastReadVideoFrameTimeMillis = timeNowMillis;
				}
			}
		
	}
#endif
}

@end

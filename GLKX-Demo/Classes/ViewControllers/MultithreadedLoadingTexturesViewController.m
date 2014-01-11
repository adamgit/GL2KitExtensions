#import "MultithreadedLoadingTexturesViewController.h"

#import "GLKX_Library.h"

#import "GLK2Texture.h"

#import "GLK2Texture+CoreGraphics.h"

#import "CommonGLEngineCode.h"

@interface MultithreadedLoadingTexturesViewController ()

@end

@implementation MultithreadedLoadingTexturesViewController

/** Override and trigger a background thread to upload textures to a new EAGLContext instance */
-(void)viewDidLoad
{
	[super viewDidLoad];
	
	
}

-(NSMutableArray*) createAllDrawCalls
{	
	/** All the local setup for the ViewController */
	NSMutableArray* result = [NSMutableArray array];
	
	/**
	 Rotating cube with simple CALayer texture ("real" texture will be loaded asynch)
	 */
	
	GLK2DrawCall* dcCube = [CommonGLEngineCode drawCallWithUnitCubeAtOriginUsingShaders:
						   [GLK2ShaderProgram shaderProgramFromVertexFilename:@"VertexProjectedWithTexture" fragmentFilename:@"FragmentWithTexture"]];
	
	/** Do some drawing to a CGContextRef */
	CGContextRef cgContext = [GLK2Texture createCGContextForOpenGLTextureRGBAWidth:256 h:256 bitsPerPixel:8 shouldFlipY:FALSE fillColorOrNil:[UIColor whiteColor]];
	CGContextSetFillColorWithColor( cgContext, [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1].CGColor );
	UIGraphicsPushContext( cgContext ); // so we can use Apple's badly-designed NSString methods
	NSString* message = @"Loading\nPlease Wait";
	[message drawInRect:CGRectMake(0,0,256,256) withFont:[UIFont systemFontOfSize:70]];
	UIGraphicsPopContext();
	
	/** Convert the CGContext into a GL texture */
	GLK2Texture* newTexture = [GLK2Texture uploadTextureRGBAToOpenGLFromCGContext:cgContext width:256 height:256];
	
	/** Add the GL texture to our Draw call / shader so it uses it */
	GLK2Uniform* samplerTexture1 = [dcCube.shaderProgram uniformNamed:@"s_texture1"];
	[dcCube setTexture:newTexture forSampler:samplerTexture1];
	
	/** Set the projection matrix to Identity (i.e. "dont change anything") */
	GLK2Uniform* uniProjectionMatrix = [dcCube.shaderProgram uniformNamed:@"projectionMatrix"];
	GLKMatrix4 rotatingProjectionMatrix = GLKMatrix4Identity;
	[dcCube.shaderProgram setValueOutsideRenderLoopRestoringProgramAfterwards:&rotatingProjectionMatrix forUniform:uniProjectionMatrix];
	
	[result addObject:dcCube];
	
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
}

@end

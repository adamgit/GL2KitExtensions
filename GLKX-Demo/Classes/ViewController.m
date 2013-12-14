/**
 Version 1: c.f. http://t-machine.org/index.php/2013/09/08/opengl-es-2-basic-drawing/
 Part 3: ... not published yet ...
 */
#import "ViewController.h"

#import "GLKX_Library.h"

@interface ViewController ()
@property(nonatomic, retain) NSMutableArray* drawCalls;
@end

@implementation ViewController

- (void)dealloc
{
    if ([EAGLContext currentContext] == self.localContext) {
        [EAGLContext setCurrentContext:nil];
    }
    
    self.localContext = nil;
	
    [super dealloc];
}

-(void) viewDidLoad
{
	[super viewDidLoad];
	
	self.preferredFramesPerSecond = 60;
	
	/*****************************************************
	 Creating and "making current" an EAGLContext must be
	 the very first thing any OpenGL app does!
	 */
	if( self.localContext == nil )
	{
		self.localContext = [[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2] autorelease];
	}
	NSAssert( self.localContext != nil, @"Failed to create ES context");
	[EAGLContext setCurrentContext:self.localContext]; // VERY important! GL silently stops working without this
	
	/*****************************************************
	 Finish enabling GL rendering by:
	    - giving the GLKView an EAGLContext to render to
	    - "bindDrawable" (in GL terms: this is identical to binding the screen's FrameBufferObject)
	    - ... DO NOT mess with delegates; GLKViewController did that already, automatically, for you
	 
	 ...NB: ideally, we would do this AFTER creating all drawcalls etc. However, some internal Apple
	 state crashes/errors/fails (some of each!) if you haven't called bindDrawable yet.
	 
	 WORSE: ***** NOTE CAREFULLY! ***** there are CRITICAL bugs in Apple's GLKView class that it will
	      *** CRASH OPENGL *** if you try to get a valid framebuffer so you can setup GL, then configure your GLKView.
	      GLKView has inadequate internal state-management, and corrupts itself, dependent on what you changed.
	      Just: don't. It's not worth fighting Apple's undocumented behaviour!
	 */
	GLKView *view = (GLKView *)self.view;
	view.context = self.localContext;
	view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
	[view bindDrawable];
	
	/*****************************************************
	 One-time read of hardware info
	 */
	self.hardwareMaximums = [[GLK2HardwareMaximums new] autorelease];
	[self.hardwareMaximums readAllGLMaximums];
	
	/*****************************************************
	 This is the main thing that changes from app to app: the set of draw-calls
	 */
	self.drawCalls = [self createAllDrawCalls];
}

-(NSMutableArray*) createAllDrawCalls
{	
	/** All the local setup for the ViewController */
	NSMutableArray* result = [NSMutableArray array];
	
	/** -- Draw Call 1:
	 
	 clear the background
	 */
	GLK2DrawCall* simpleClearingCall = [[GLK2DrawCall new] autorelease];
	simpleClearingCall.shouldClearColorBit = TRUE;
	[result addObject: simpleClearingCall];
	
		/* draw a TEXTURED pair of 2 triangles onto the screen, arranged into a square ("quad")
		 */
		GLK2DrawCall* drawTexturedQuad = [[GLK2DrawCall new] autorelease];
		drawTexturedQuad.numVerticesToDraw = 6;
	drawTexturedQuad.shaderProgram = [GLK2ShaderProgram shaderProgramFromVertexFilename:@"VertexTextureMappingUnprojected" fragmentFilename:@"FragmentTextureMapOnly"];
	glUseProgram( drawTexturedQuad.shaderProgram.glName );
	
	float z = -0.4;
	GLKVector3 cpuBufferQuad[6] =
		{
			GLKVector3Make(-0.5,-0.5, z),
			GLKVector3Make(-0.5, 0.5, z),
			GLKVector3Make( 0.5, 0.5, z),
			GLKVector3Make(-0.5,-0.5, z),
			GLKVector3Make( 0.5, 0.5, z),
			GLKVector3Make( 0.5,-0.5, z)
		};
		GLKVector2 attributesVirtualXY [6] =
		{
			GLKVector2Make( 0, 0 ), // note: we vary the virtual x and y as if they were x,y co-ords on a right-angle triangle
			GLKVector2Make( 0, 1 ),
			GLKVector2Make( 1, 1 ),
			GLKVector2Make( 0, 0 ), // note: we vary the virtual x and y as if they were x,y co-ords on a right-angle triangle
			GLKVector2Make( 1, 1 ),
			GLKVector2Make( 1, 0 )
		};
		
		drawTexturedQuad.VAO = [[GLK2VertexArrayObject new] autorelease];
	
	GLK2Attribute* attributePosition = [drawTexturedQuad.shaderProgram attributeNamed:@"position"];
		[drawTexturedQuad.VAO addVBOForAttribute:attributePosition filledWithData:cpuBufferQuad bytesPerArrayElement:sizeof(GLKVector3) arrayLength:drawTexturedQuad.numVerticesToDraw];
		
		GLK2Attribute* attXY = [drawTexturedQuad.shaderProgram attributeNamed:@"a_virtualXY"];
		[drawTexturedQuad.VAO addVBOForAttribute:attXY filledWithData:attributesVirtualXY bytesPerArrayElement:sizeof(GLKVector2) arrayLength:drawTexturedQuad.numVerticesToDraw];

	/** make the texture repeat infinitely if it's smaller than the object it's mapped onto */
	//glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	//glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	
	NSError* error;
	GLKTextureInfo* appleTextureMetadata = [GLKTextureLoader textureWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tex2" ofType:@"png"] options:nil error:&error];
	NSAssert( appleTextureMetadata != nil, @"Error loading texture: %@", error);
	GLK2Texture* texture = [[GLK2Texture texturePreLoadedByApplesGLKit:appleTextureMetadata] retain];
	
	GLK2Uniform* uniformTextureSampler = [drawTexturedQuad.shaderProgram uniformNamed:@"s_texture"];

	/**   ... store the sampler and texture in the Draw call, and configure it to use them */
	[drawTexturedQuad setTexture:texture forSampler:uniformTextureSampler];
	
	/**   ... Finally: add the draw Call 2 into the list of draw-calls we're rendering as a "frame" on-screen */
	[result addObject: drawTexturedQuad];
	
	return result;
}

-(void) update
{
	[self renderSingleFrame];
}

int indexOfCurrentParameterizedDrawcall = 0;
-(void) renderSingleFrame
{
	if( [EAGLContext currentContext] == nil ) // skip until we have a context
	{
		NSLog(@"We have no gl context; skipping all frame rendering");
		return;
	}
	
	if( self.drawCalls == nil || self.drawCalls.count < 1 )
		NSLog(@"no drawcalls specified; rendering nothing");
	
	indexOfCurrentParameterizedDrawcall = 0; // reset it
	for( GLK2DrawCall* drawCall in self.drawCalls )
	{
		[self renderSingleDrawCall:drawCall];
	}
}

-(void) renderSingleDrawCall:(GLK2DrawCall*) drawCall
{
	//gl2CheckAndClearAllErrors();
	
	/** First: Clear (color, depth, or both) */
	float* newClearColour = [drawCall clearColourArray];
	glClearColor( newClearColour[0], newClearColour[1], newClearColour[2], newClearColour[3] );
	glClear( (drawCall.shouldClearColorBit ? GL_COLOR_BUFFER_BIT : 0) );
	
	/** Choose a ShaderProgram on the GPU for it to execute while doing this draw-call */
	if( drawCall.shaderProgram != nil )
		glUseProgram( drawCall.shaderProgram.glName);
	else
		glUseProgram( 0 /** means "none */ );
	
	if( drawCall.VAO != nil )
		glBindVertexArrayOES( drawCall.VAO.glName );
	//else PROBLEM: unbinding causes us to lose the texture in textureSimpl2, and I have no idea why
		//glBindVertexArrayOES( 0 /** means "none */ );
	
	
	for( GLK2Uniform* sampler in drawCall.texturesFromSamplers )
	{
		GLK2Texture* texture = [drawCall.texturesFromSamplers objectForKey:sampler];
		NSLog(@"RENDER: Binding and enabling texture sampler '%@', putting texture: %i into texture unit: %i", sampler.nameInSourceFile, texture.glName, GL_TEXTURE0 + [drawCall textureUnitOffsetForSampler:sampler] );
		
		glActiveTexture( GL_TEXTURE0 + [drawCall textureUnitOffsetForSampler:sampler] );
		glBindTexture( GL_TEXTURE_2D, texture.glName);
	}
	
	/** Finally: kick-off the draw-call, telling GL how to interpret the data we've given it (triangles, lines, points - or a variation of one of those) */
	glDrawArrays( GL_TRIANGLES, 0, drawCall.numVerticesToDraw );
}

@end

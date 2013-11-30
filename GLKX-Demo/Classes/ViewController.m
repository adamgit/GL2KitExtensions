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
	
	/** -- Draw Call 2:
	 
	 draw a triangle onto the screen
	 */
	GLK2ShaderProgram* sharedProgramForBlueTriangles = [GLK2ShaderProgram shaderProgramFromVertexFilename:@"VertexPositionUnprojectedAndShifted" fragmentFilename:@"FragmentXYParameterized"];
	//GLK2ShaderProgram* sharedProgramForBlueTriangles = [GLK2ShaderProgram shaderProgramFromVertexFilename:@"VertexPositionUnprojected" fragmentFilename:@"FragmentColourOnly"];

	/**   ... Make some geometry */
	
	GLfloat z = -0.5; // must be more than -1 * zNear, and ABS() less than zFar
	GLKVector3 cpuBuffer[3] = 
	{
		GLKVector3Make(-1,  -1, z),
		GLKVector3Make(-0.5, 0, z),
		GLKVector3Make( 0,  -1, z)
	};
	GLK2BufferObject* sharedVBOPositions = [GLK2BufferObject newVBOFilledWithData:cpuBuffer inFormat:[GLK2BufferFormat bufferFormatWithSingleTypeOfFloats:3 bytesPerItem:sizeof(GLKVector3)] numVertices:3 updateFrequency:GLK2BufferObjectFrequencyStatic];
	
	GLKVector2 attributesVirtualXY [3] = 
	{
		GLKVector2Make( 0, 0 ),
		GLKVector2Make( 0, 1 ),
		GLKVector2Make( 1, 0 )
	};
	GLK2BufferObject* sharedVBOVirtualXYs = [GLK2BufferObject newVBOFilledWithData:attributesVirtualXY inFormat:[GLK2BufferFormat bufferFormatWithSingleTypeOfFloats:2 bytesPerItem:sizeof(GLKVector2)] numVertices:3 updateFrequency:GLK2BufferObjectFrequencyStatic];
	
	GLK2Attribute* attPosition = [sharedProgramForBlueTriangles attributeNamed:@"position"]; // will fail if you haven't called glUseProgram yet
	GLK2Attribute* attXY = [sharedProgramForBlueTriangles attributeNamed:@"virtualXY"];
	
	for( int i=0; i<4; i++ )
	{
		GLK2DrawCall* draw1Triangle = [[GLK2DrawCall new] autorelease];
		
		draw1Triangle.numVerticesToDraw = 3;
		
		/**   ... Upload a program */
		draw1Triangle.shaderProgram = sharedProgramForBlueTriangles;
		glUseProgram( draw1Triangle.shaderProgram.glName );
		
		/**   ... create a VAO to hold a VBO, and upload the geometry into that new VBO
		 
		 NOTE: our "position" attribute is a vec4 in the shader source, but we're sending GLKVector3's (not GLKVector4's).
		 This is ABSOLUTELY FINE, OpenGL will up-convert for us - but we have to warn OpenGL that the data being uploaded
		 is vec3 instead of vec4. OpenGL assumes nothing, so if we used vec4's, we'd still have to give this info. It makes
		 the code easier to read if we specify our data in vec3, upload as vec3, and let OpenGL do the final conversion.
		 */
		draw1Triangle.VAO = [[GLK2VertexArrayObject new] autorelease];
		[draw1Triangle.VAO addVBO:sharedVBOPositions forAttributes:@[attPosition] numVertices:3];

		[draw1Triangle.VAO addVBO:sharedVBOVirtualXYs forAttributes:@[attXY] numVertices:3];
		
		/**   ... Finally: add the draw Call 2 into the list of draw-calls we're rendering as a "frame" on-screen */
		[result addObject: draw1Triangle];
	}
	
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
	
	/** Finally: kick-off the draw-call, telling GL how to interpret the data we've given it (triangles, lines, points - or a variation of one of those) */
	glDrawArrays( GL_TRIANGLES, 0, drawCall.numVerticesToDraw );
}

@end

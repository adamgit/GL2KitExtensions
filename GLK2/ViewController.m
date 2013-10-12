/**
 Version 1: c.f. http://t-machine.org/index.php/2013/09/08/opengl-es-2-basic-drawing/
 Part 3: ... not published yet ...
 */
#import "ViewController.h"
#import "GLK2DrawCall.h"

#import "GLK2Shader.h"
#import "GLK2ShaderProgram.h"

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
	 This is the main thing that changes from app to app: the set of draw-calls
	 */
	self.drawCalls = [self createAllDrawCalls];
	
	/*****************************************************
	 Enable GL rendering by:
	    - giving the GLKView an EAGLContext to render to
	    - "bindDrawable" (in GL terms: this is identical to binding the screen's FrameBufferObject)
	    - ... DO NOT mess with delegates; GLKViewController did that already, automatically, for you
	 */
	GLKView *view = (GLKView *)self.view;
	view.context = self.localContext;
	view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
	[view bindDrawable];
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
	GLK2DrawCall* draw1Triangle = [[GLK2DrawCall new] autorelease];
	
	/**   ... Upload a program */
	draw1Triangle.shaderProgram = [GLK2ShaderProgram shaderProgramFromVertexFilename:@"VertexPositionUnprojected" fragmentFilename:@"FragmentColourOnly"];
	glUseProgram( draw1Triangle.shaderProgram.glName );
	
	GLK2Attribute* attribute = [draw1Triangle.shaderProgram attributeNamed:@"position"]; // will fail if you haven't called glUseProgram yet
	
	/**   ... Make some geometry */
	
	GLfloat z = -0.5; // must be more than -1 * zNear, and ABS() less than zFar
	GLKVector3 cpuBuffer[] = 
	{
	GLKVector3Make(-1,-1, z),
	GLKVector3Make( 0, 1, z),
	GLKVector3Make( 1,-1, z)
	};
	
	/**   ... create a VAO to hold a VBO, and upload the geometry into that new VBO
	          
	 NOTE: our "position" attribute is a vec4 in the shader source, but we're sending GLKVector3's (not GLKVector4's).
		This is ABSOLUTELY FINE, OpenGL will up-convert for us - but we have to warn OpenGL that the data being uploaded
		is vec3 instead of vec4. OpenGL assumes nothing, so if we used vec4's, we'd still have to give this info. It makes
	    the code easier to read if we specify our data in vec3, upload as vec3, and let OpenGL do the final conversion.
	 */
	draw1Triangle.VAO = [[GLK2VertexArrayObject new] autorelease];
	[draw1Triangle.VAO addVBOForAttribute:attribute filledWithData:cpuBuffer bytesPerArrayElement:sizeof(GLKVector3) arrayLength:3];
	
	/**   ... Finally: add the draw Call 2 into the list of draw-calls we're rendering as a "frame" on-screen */
	[result addObject: draw1Triangle];
	
	return result;
}

-(void) update
{
	[self renderSingleFrame];
}

-(void) renderSingleFrame
{
	if( [EAGLContext currentContext] == nil ) // skip until we have a context
	{
		NSLog(@"We have no gl context; skipping all frame rendering");
		return;
	}
	
	if( self.drawCalls == nil || self.drawCalls.count < 1 )
		NSLog(@"no drawcalls specified; rendering nothing");
	
	for( GLK2DrawCall* drawCall in self.drawCalls )
	{
		[self renderSingleDrawCall:drawCall];
	}
}

-(void) renderSingleDrawCall:(GLK2DrawCall*) drawCall
{
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
	else
		glBindVertexArrayOES( 0 /** means "none */ );
	
	/** Finally: kick-off the draw-call, telling GL how to interpret the data we've given it (triangles, lines, points - or a variation of one of those) */
	glDrawArrays( GL_TRIANGLES, 0, 3);
}
@end

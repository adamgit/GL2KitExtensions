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
	
	/** Creating and "making current" an EAGLContext must be the very first thing any OpenGL app does! */
	if( self.localContext == nil )
	{
		self.localContext = [[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2] autorelease];
	}
	NSAssert( self.localContext != nil, @"Failed to create ES context");
	[EAGLContext setCurrentContext:self.localContext]; // VERY important! GL silently stops working without this
	
	/** Enable GL rendering by enabling the GLKView (enable it by giving it an EAGLContext to render to) */
	GLKView *view = (GLKView *)self.view;
	view.context = self.localContext;
	view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
	[view bindDrawable];
	
	/** All the local setup for the ViewController */
	self.drawCalls = [NSMutableArray array];
	
	/** -- Draw Call 1: clear the background */
	GLK2DrawCall* simpleClearingCall = [[GLK2DrawCall new] autorelease];
	simpleClearingCall.shouldClearColorBit = TRUE;
	[self.drawCalls addObject: simpleClearingCall];
	
	/** -- Draw Call 2: draw a triangle onto the screen */
	GLK2DrawCall* draw1Triangle = [[GLK2DrawCall new] autorelease];
	
	/**   ... Upload a program */
	draw1Triangle.shaderProgram = [GLK2ShaderProgram shaderProgramFromVertexFilename:@"VertexPositionUnprojected" fragmentFilename:@"FragmentColourOnly"];
	glUseProgram( draw1Triangle.shaderProgram.glName );
	
	GLK2Attribute* attribute = [draw1Triangle.shaderProgram attributeNamed:@"position"]; // will fail if you haven't called glUseProgram yet
	
	/**   ... Make some geometry */
	
	GLfloat z = -0.5; // must be more than -1 * zNear, and ABS() less than zFar
	GLKVector3* cpuBuffer = malloc( sizeof(GLKVector3) * 3 );
	cpuBuffer[0] = GLKVector3Make(-1,-1, z);
	cpuBuffer[1] = GLKVector3Make( 0, 1, z);
	cpuBuffer[2] = GLKVector3Make( 1,-1, z);
	
	/**   ... Configure the VAO (state) + VBO (vertex data) for self */
	GLuint VAOName, VBOName;
	glGenVertexArraysOES(1, &VAOName ); // this uses address-of, so MUST use the underscore version in Objective-C
	glBindVertexArrayOES( VAOName );
	
	glGenBuffers( 1, &VBOName );
 	glBindBuffer(GL_ARRAY_BUFFER, VBOName );
	glBufferData(GL_ARRAY_BUFFER, 3 * sizeof( GLKVector3 ), cpuBuffer, GL_DYNAMIC_DRAW);
	
	/**   ... Tell OpenGL "how" the attribute "position" is stored/packed into the stream of bytes we just uploaded */
	glEnableVertexAttribArray( attribute.glLocation );
	glVertexAttribPointer( attribute.glLocation, 3, GL_FLOAT, GL_FALSE, 0, 0);
	
	/**   ... Finally: add the draw Call 2 into the list of draw-calls we're rendering as a "frame" on-screen */
	[self.drawCalls addObject: draw1Triangle];
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
	
	/** Finally: kick-off the draw-call, telling GL how to interpret the data we've given it (triangles, lines, points - or a variation of one of those) */
	glDrawArrays( GL_TRIANGLES, 0, 3);
}
@end

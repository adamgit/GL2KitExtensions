/**
 Version 1: c.f. http://t-machine.org/index.php/2013/09/08/opengl-es-2-basic-drawing/
 */
#import "ViewController.h"
#import "GLK2DrawCall.h"

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
    
	/** All the local setup for the ViewController */
	self.drawCalls = [NSMutableArray array];
	GLK2DrawCall* simpleClearingCall = [[GLK2DrawCall new] autorelease];
	simpleClearingCall.shouldClearColorBit = TRUE;
	[self.drawCalls addObject: simpleClearingCall];
	
	/** Finally: enable GL rendering by enabling the GLKView (enable it by giving it an EAGLContext to render to) */
	GLKView *view = (GLKView *)self.view;
	view.context = self.localContext;
	view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
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
	/** clear (color, depth, or both) */
	float* newClearColour = [drawCall clearColourArray];
	glClearColor( newClearColour[0], newClearColour[1], newClearColour[2], newClearColour[3] );
	glClear( (drawCall.shouldClearColorBit ? GL_COLOR_BUFFER_BIT : 0) );
}
@end

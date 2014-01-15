#import "GLK2DrawCallViewController.h"

#import "GLKX_Library.h"

#pragma mark - Class Extension (private properties etc)
@interface GLK2DrawCallViewController ()

@end

#pragma mark - Main Class
@implementation GLK2DrawCallViewController
{
}

/** Apple ignores their own designated initializer until iOS 6, so we workaround Apple */
-(void) designatedInitializerWorkaround
{
	
}

/** Apple Storyboards ONLY call this method */
-(id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
    if (self) {
        [self designatedInitializerWorkaround];
    }
    return self;
}

/** In source code, you can ONLY call this method */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self designatedInitializerWorkaround];
    }
    return self;
}

- (void)dealloc
{
    if ([EAGLContext currentContext] == self.localContext)
	{
        [EAGLContext setCurrentContext:nil];
    }
    
    self.localContext = nil;
	
    [super dealloc];
}

#pragma mark - Callbacks for subclasses

-(NSMutableArray *)createAllDrawCalls
{
	// subclasses SHOULD override (they don't have to; BUT: its unusual not to!)
	
	NSLog(@"Subclass should have overridden this method (createAllDrawCalls)");
	
	return [NSMutableArray array];
}

-(void)willRenderFrame
{
	// subclasses CAN override (but don't have to!) 
}

-(void)willRenderDrawCallUsingVAOShaderProgramAndDefaultUniforms:(GLK2DrawCall *)drawCall
{
	// subclasses SHOULD override
}

#pragma mark - Apple UIKit lifecycle methods

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

#pragma mark - Core public methods 

-(void) update
{
	[self willRenderFrame];
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
	else
	{
		/**
		 REQUIRED by PVR chips (even though it's technically incorrect
		 - if you wanted to do a coloured clear etc).
		 
		 You'll later have to disable/re-enable the depth-test as required,
		 but doing this unncessary clear gives a 10%+ increase in frame rate,
		 so it's a necessity!
		 */
		{
			glEnable( GL_DEPTH_TEST );
			glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
		}
		
		for( GLK2DrawCall* drawCall in self.drawCalls )
		{
			[self renderSingleDrawCall:drawCall];
		}
	}
}

-(void) renderSingleDrawCall:(GLK2DrawCall*) drawCall
{
	/**
	 Switch to the correct VAO */
	
	if( drawCall.VAO != nil )
		glBindVertexArrayOES( drawCall.VAO.glName );
	//else PROBLEM: unbinding causes us to lose the texture in textureSimpl2, and I have no idea why
	//glBindVertexArrayOES( 0 /** means "none */ );
	
	/**
	 Choose a ShaderProgram on the GPU for it to execute while doing this draw-call,
	 and restore the Uniforms (which GL should do as part of the VAO, but sadly doesn't)
	 */
	
	if( drawCall.shaderProgram != nil )
		glUseProgram( drawCall.shaderProgram.glName);
	else
		glUseProgram( 0 /** means "none */ );
	
	/** Set uniforms to defaults */
	[drawCall setAllUniformValuesForShader];
	
	[self willRenderDrawCallUsingVAOShaderProgramAndDefaultUniforms:drawCall];
	
	/**
	 First: Clear (color, depth, or both)
	 
	 (Apple/hardware issue: always aim to do a glClear, unless you visually can't; in some cases,
	 it helps with performance to do the clear - even if not needed)*/
	
	float* newClearColour = [drawCall clearColourArray];
	glClearColor( newClearColour[0], newClearColour[1], newClearColour[2], newClearColour[3] );
	glClear( (drawCall.shouldClearColorBit ? GL_COLOR_BUFFER_BIT : 0) );
	
	if( drawCall.requiresCullFace )
		glEnable(  GL_CULL_FACE );
	else
		glDisable( GL_CULL_FACE );
	
	/**
	 Re-bind / enable all the textures for this Draw call */
	for( GLK2Uniform* sampler in drawCall.texturesFromSamplers )
	{
		GLK2Texture* texture = [drawCall.texturesFromSamplers objectForKey:sampler];
		//DEBUG: NSLog(@"RENDER: Binding and enabling texture sampler '%@', putting texture: %i into texture unit: %i", sampler.nameInSourceFile, texture.glName, GL_TEXTURE0 + [drawCall textureUnitOffsetForSampler:sampler] );
		
		glActiveTexture( GL_TEXTURE0 + [drawCall textureUnitOffsetForSampler:sampler] );
		glBindTexture( GL_TEXTURE_2D, texture.glName);
	}
	
	/** Finally: kick-off the draw-call, telling GL how to interpret the data we've given it (triangles, lines, points - or a variation of one of those) */
	if( drawCall.glDrawCallType != 0 && drawCall.numVerticesToDraw == 0 )
		NSLog(@"Warning: you have chosen a geometry draw-call, but supplied 0 vertices; usually this means you forgot to set drawCall.numVerticesToDraw. Set the glDrawCallType to 0 to suppress this warning" );
	
	if( drawCall.glDrawCallType == 0 && drawCall.numVerticesToDraw != 0 )
		NSLog(@"Warning: you have specified a number of vertices, but not told me what kind of Draw call this is; you probably forget to set it to e.g. GL_TRIANGLES. To suppress this warning, set the numVerticesToDraw = 0");
	
	glDrawArrays( drawCall.glDrawCallType, 0, drawCall.numVerticesToDraw );
}

@end

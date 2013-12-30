#import "GLK2DrawCallViewController.h"

#import "GLKX_Library.h"
#import "GLK2TextureManager.h"

#pragma mark - Class Extension (private properties etc)
@interface GLK2DrawCallViewController ()
@property(nonatomic, retain) NSMutableArray* drawCalls;
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
	 One-time read of hardware info
	 */
	self.hardwareMaximums = [[GLK2HardwareMaximums new] autorelease];
	[self.hardwareMaximums readAllGLMaximums];
	
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
	
#if DISABLED_FOR_NOW_BECAUSE_NOT_BEING_USED_ANY_MORE
	for( GLK2Texture* texture in [GLK2TextureManager allKnownGLK2Textures])
	{
		if( texture.shouldReleaseAtEndOfNextFrame )
		{
			texture.shouldReleaseAtEndOfNextFrame = FALSE;
			[texture release];
		}
	}
#endif
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
	[self setAllUniformValuesForShaderInDrawCall:drawCall];
	
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

-(void) setAllUniformValuesForShaderInDrawCall:(GLK2DrawCall*) drawCall
{
	if( drawCall.uniformValueGenerator != nil )
	{
		for( GLK2Uniform* uniform in [drawCall.shaderProgram allUniforms] )
		{			
			if( uniform.isFloat )
			{
				float* floatPointer = NULL;
				if( uniform.isMatrix )
				{
					switch( uniform.matrixWidth )
					{
						case 2:
						{
							GLKMatrix2* matrixValue = [drawCall.uniformValueGenerator matrix2ForUniform:uniform inDrawCall:drawCall];
							floatPointer = matrixValue->m;
						}break;
						case 3:
						{
							GLKMatrix3* matrixValue = [drawCall.uniformValueGenerator matrix3ForUniform:uniform inDrawCall:drawCall];
							floatPointer = matrixValue->m;
						}break;
						case 4:
						{
							GLKMatrix4* matrixValue = [drawCall.uniformValueGenerator matrix4ForUniform:uniform inDrawCall:drawCall];
							floatPointer = matrixValue->m;
						}break;
					}
				}
				else if( uniform.isVector )
				{
					switch( uniform.vectorWidth )
					{
						case 2:
						{
							GLKVector2* vectorValue = [drawCall.uniformValueGenerator vector2ForUniform:uniform inDrawCall:drawCall];
							floatPointer = vectorValue->v;
						}break;
						case 3:
						{
							GLKVector3* vectorValue = [drawCall.uniformValueGenerator vector3ForUniform:uniform inDrawCall:drawCall];
							floatPointer = vectorValue->v;
						}break;
						case 4:
						{
							GLKVector4* vectorValue = [drawCall.uniformValueGenerator vector4ForUniform:uniform inDrawCall:drawCall];
							floatPointer = vectorValue->v;
						}break;
					}
				}
				else
				{
					if( ! [drawCall.uniformValueGenerator floatForUniform:uniform returnIn:floatPointer inDrawCall:drawCall] )
						floatPointer = 0; // kill the pointer
				}
				
				if( floatPointer != NULL ) // prevent the next line from clobbering the value!
					[drawCall.shaderProgram setValue:floatPointer forUniform:uniform];
			}
			else
			{
				int* intPointer = NULL;
				if( uniform.isVector )
				{
					NSAssert(FALSE, @"Int vectors not supported yet");
				}
				else
				{
					if( ! [drawCall.uniformValueGenerator intForUniform:uniform returnIn:intPointer inDrawCall:drawCall] )
						intPointer = 0; // kill the pointer
				}
				
				if( intPointer != NULL ) // prevent the next line from clobbering the value!
					[drawCall.shaderProgram setValue:intPointer forUniform:uniform];
				
			}
		}
	}
	
}

@end

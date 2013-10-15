/**
 Version 1: c.f. http://t-machine.org/index.php/2013/09/08/opengl-es-2-basic-drawing/
 Part 3: ... not published yet ...
 */
#import "ViewController.h"
#import "GLK2DrawCall.h"

#import "GLK2Shader.h"
#import "GLK2ShaderProgram.h"

#import "GLK2GetError.h"

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
	draw1Triangle.numVerticesToDraw = 3;
	GLKVector3 cpuBuffer[3] = 
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
	[draw1Triangle.VAO addVBOForAttribute:attribute filledWithData:cpuBuffer bytesPerArrayElement:sizeof(GLKVector3) arrayLength: draw1Triangle.numVerticesToDraw];
	
	/**   ... Finally: add the draw Call 2 into the list of draw-calls we're rendering as a "frame" on-screen */
	[result addObject: draw1Triangle];
	
	
	/** -- Draw Call 3:
	 
	 draw a TEXTURED pair of 2 triangles onto the screen, arranged into a square ("quad")
	 */
	GLK2DrawCall* drawTexturedQuad = [[GLK2DrawCall new] autorelease];
	
	/** load a simple texture, using Apple: */
	NSError* error;
	
	GLKTextureInfo* appleTextureMetadata = [GLKTextureLoader textureWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"black-with-white-stripe" ofType:@"png"] options:nil error:&error];
	if( appleTextureMetadata == nil )
		NSLog(@"error loading texture: %@", error);
	
	GLK2Texture* textureSimple = [GLK2Texture texturePreLoadedByApplesGLKit:appleTextureMetadata];
	
	GLKTextureInfo* appleTextureMetadata2 = [GLKTextureLoader textureWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tex2" ofType:@"png"] options:nil error:&error];
	if( appleTextureMetadata2 == nil )
		NSLog(@"error loading texture: %@", error);
	
	GLK2Texture* textureSimpl2 = [[GLK2Texture texturePreLoadedByApplesGLKit:appleTextureMetadata2] retain];
	
	/** make the texture repeat infinitely if it's smaller than the object it's mapped onto */
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	
	drawTexturedQuad.shaderProgram = [GLK2ShaderProgram shaderProgramFromVertexFilename:@"VertexUnprojectedWithTexture" fragmentFilename:@"FragmentTextureOnly"];
	glUseProgram( drawTexturedQuad.shaderProgram.glName );
	
	GLK2Attribute* attributePosition = [drawTexturedQuad.shaderProgram attributeNamed:@"position"]; // will fail if you haven't called glUseProgram yet
	GLK2Attribute* attributeTexCoord = [drawTexturedQuad.shaderProgram attributeNamed:@"textureCoordinate"]; // will fail if you haven't called glUseProgram yet
	GLK2Uniform* uniformTextureSampler = [drawTexturedQuad.shaderProgram uniformNamed:@"s_texture1"];
	GLK2Uniform* uniformTextureSampler2 = [drawTexturedQuad.shaderProgram uniformNamed:@"s2"];
	
	/**   ... Make some geometry */
	drawTexturedQuad.numVerticesToDraw = 6;
	GLKVector3 cpuBufferQuad[6] = 
	{
		GLKVector3Make(-0.5,-0.5, z),
		GLKVector3Make(-0.5, 0.5, z),
		GLKVector3Make( 0.5, 0.5, z),
		
		GLKVector3Make( 0.5, 0.4, z),
		GLKVector3Make( 0.4,-0.6, z),
		GLKVector3Make(-0.4,-0.4, z)
	};
	
	/**   ... TEXTURE the geometry */
	
	GLKVector2 cpuBufferQuadTextureCoords[6] = 
	{
		GLKVector2Make( 0, 0),
		GLKVector2Make( 0, 1.0),
		GLKVector2Make( 1.0, 1.0),
		
		GLKVector2Make( 1.0, 1.0),
		GLKVector2Make( 1.0, 0),
		GLKVector2Make( 0, 0)
	};
	
	/**   ... create a VAO to hold a VBO, and upload the geometry into that new VBO
	 
	 NOTE: our "position" attribute is a vec4 in the shader source, but we're sending GLKVector3's (not GLKVector4's).
	 This is ABSOLUTELY FINE, OpenGL will up-convert for us - but we have to warn OpenGL that the data being uploaded
	 is vec3 instead of vec4. OpenGL assumes nothing, so if we used vec4's, we'd still have to give this info. It makes
	 the code easier to read if we specify our data in vec3, upload as vec3, and let OpenGL do the final conversion.
	 */
	drawTexturedQuad.VAO = [[GLK2VertexArrayObject new] autorelease];
	[drawTexturedQuad.VAO addVBOForAttribute:attributePosition filledWithData:cpuBufferQuad bytesPerArrayElement:sizeof(GLKVector3) arrayLength:drawTexturedQuad.numVerticesToDraw];
	[drawTexturedQuad.VAO addVBOForAttribute:attributeTexCoord filledWithData:cpuBufferQuadTextureCoords bytesPerArrayElement:sizeof(GLKVector2) arrayLength:drawTexturedQuad.numVerticesToDraw];
	
	/**   ... store the sampler : texture mappings */
	[drawTexturedQuad setTexture:textureSimple forSampler:uniformTextureSampler];
	[drawTexturedQuad setTexture:textureSimpl2 forSampler:uniformTextureSampler2];
#if TRUE
	for( GLK2Uniform* sampler in drawTexturedQuad.texturesFromSamplers )
	{
		glUniform1i( sampler.glLocation, [drawTexturedQuad textureUnitOffsetForSampler:sampler] );
	}
#endif
	
	/**   ... Finally: add the draw Call 2 into the list of draw-calls we're rendering as a "frame" on-screen */
	[result addObject: drawTexturedQuad];
	
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
	
	GLK2Uniform* uniformTexOffsetU = [drawCall.shaderProgram uniformNamed:@"textureOffsetU"]; // will fail if you haven't called glUseProgram yet
	if( uniformTexOffsetU != nil )
	{
		int framesOutOfFramesPerSecond = self.framesDisplayed % self.framesPerSecond;
		
		float newOffset = (framesOutOfFramesPerSecond / (float) self.framesPerSecond);
		[drawCall.shaderProgram setValue:&newOffset forUniform:uniformTexOffsetU];
	}
	
#if TRUE
	for( GLK2Uniform* sampler in drawCall.texturesFromSamplers )
	{
		GLK2Texture* texture = [drawCall.texturesFromSamplers objectForKey:sampler];
		NSLog(@"RENDER: Binding and enabling texture sampler '%@', putting texture: %i into texture unit: %i", sampler.nameInSourceFile, texture.glName, GL_TEXTURE0 + [drawCall textureUnitOffsetForSampler:sampler] );
		
		glActiveTexture( GL_TEXTURE0 + [drawCall textureUnitOffsetForSampler:sampler] );
		glBindTexture( GL_TEXTURE_2D, texture.glName);
	}
#endif
	
	/** Finally: kick-off the draw-call, telling GL how to interpret the data we've given it (triangles, lines, points - or a variation of one of those) */
	glDrawArrays( GL_TRIANGLES, 0, drawCall.numVerticesToDraw );
}
@end

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
	
#define SHOW_2_NOT_3 1
#if SHOW_2_NOT_3
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
	
#else
#define DRAWCALL3_IS_TEXTURES_NOT_ALGORITHMIC 0
#if DRAWCALL3_IS_TEXTURES_NOT_ALGORITHMIC
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
	
	/**   ... Finally: add the draw Call 2 into the list of draw-calls we're rendering as a "frame" on-screen */
	[result addObject: drawTexturedQuad];

#else

	/** -- Draw Call 3:
	 
	 draw a ALGO FAKE-TEXTURED pair of 2 triangles onto the screen, arranged into a square ("quad")
	 */
	GLK2DrawCall* drawFakeTexturedQuad = [[GLK2DrawCall new] autorelease];
	
	drawFakeTexturedQuad.shaderProgram = [GLK2ShaderProgram shaderProgramFromVertexFilename:@"VertexPassThroughAlgorithmData" fragmentFilename:@"FragmentFunkyAlgorithm1"];
	glUseProgram( drawFakeTexturedQuad.shaderProgram.glName );
	
	GLK2Attribute* attributePosition = [drawFakeTexturedQuad.shaderProgram attributeNamed:@"position"]; // will fail if you haven't called glUseProgram yet
	GLK2Attribute* attributeAlgoX = [drawFakeTexturedQuad.shaderProgram attributeNamed:@"algorithmVirtualX"]; // will fail if you haven't called glUseProgram yet
	GLK2Attribute* attributeAlgoY = [drawFakeTexturedQuad.shaderProgram attributeNamed:@"algorithmVirtualY"]; // will fail if you haven't called glUseProgram yet
	
	/**   ... Make some geometry */
	drawFakeTexturedQuad.numVerticesToDraw = 3;
	GLKVector3 cpuBufferQuad[3] = 
	{
		GLKVector3Make(-0.5,-0.5, z),
		GLKVector3Make(-0.5, 0.5, z),
		GLKVector3Make( 0.5, 0.5, z)
	};
	
	/**   ... attach a virtual X and Y value to the geometry, that our shader will "interpret" later */
	
	float frequencyIncreaserX = 4;
	float frequencyIncreaserY = 2.8;
	GLfloat cpuBufferQuadVirtualXs[3] = 
	{
		0,
		0,
		1 * frequencyIncreaserX
	};
	GLfloat cpuBufferQuadVirtualYs[3] = 
	{
		0,
		1 * frequencyIncreaserY,
		1 * frequencyIncreaserY
	};
	
	/**   ... create a VAO to hold a VBO, and upload the geometry into that new VBO
	 
	 NOTE: our "position" attribute is a vec4 in the shader source, but we're sending GLKVector3's (not GLKVector4's).
	 This is ABSOLUTELY FINE, OpenGL will up-convert for us - but we have to warn OpenGL that the data being uploaded
	 is vec3 instead of vec4. OpenGL assumes nothing, so if we used vec4's, we'd still have to give this info. It makes
	 the code easier to read if we specify our data in vec3, upload as vec3, and let OpenGL do the final conversion.
	 */
	drawFakeTexturedQuad.VAO = [[GLK2VertexArrayObject new] autorelease];
	[drawFakeTexturedQuad.VAO addVBOForAttribute:attributePosition filledWithData:cpuBufferQuad bytesPerArrayElement:sizeof(GLKVector3) arrayLength:drawFakeTexturedQuad.numVerticesToDraw];
	[drawFakeTexturedQuad.VAO addVBOForAttribute:attributeAlgoX filledWithData:cpuBufferQuadVirtualXs bytesPerArrayElement:sizeof(GLfloat) arrayLength:drawFakeTexturedQuad.numVerticesToDraw];
	[drawFakeTexturedQuad.VAO addVBOForAttribute:attributeAlgoY filledWithData:cpuBufferQuadVirtualYs bytesPerArrayElement:sizeof(GLfloat) arrayLength:drawFakeTexturedQuad.numVerticesToDraw];
		
	/**   ... Finally: add the draw Call into the list of draw-calls we're rendering as a "frame" on-screen */
	[result addObject: drawFakeTexturedQuad];
#endif
#endif
	
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
	
	[self setAllUniformValuesForShaderInDrawCall:drawCall];
	
	GLK2Uniform* uniPositionOffset = [drawCall.shaderProgram uniformNamed:@"positionOffset" ];	
	if( uniPositionOffset != nil )
	{
		GLKVector2 offset = GLKVector2Make( indexOfCurrentParameterizedDrawcall%2, indexOfCurrentParameterizedDrawcall/2 );
		[drawCall.shaderProgram setValue:&offset forUniform:uniPositionOffset];
		
		indexOfCurrentParameterizedDrawcall++;
	}
	
	GLK2Uniform* uniformTexOffsetU = [drawCall.shaderProgram uniformNamed:@"textureOffsetU"]; // will fail if you haven't called glUseProgram yet
	if( uniformTexOffsetU != nil )
	{
		long framesOutOfFramesPerSecond = self.framesDisplayed % self.framesPerSecond;
		
		float newOffset = (framesOutOfFramesPerSecond / (float) self.framesPerSecond);
		[drawCall.shaderProgram setValue:&newOffset forUniform:uniformTexOffsetU];
	}
	
	GLK2Uniform* uniformTimeInSecs = [drawCall.shaderProgram uniformNamed:@"timeInSeconds"]; // will fail if you haven't called glUseProgram yet
	if( uniformTimeInSecs != nil )
	{
		//double newValue = self.framesDisplayed / 60.0;
		
		long framesOutOfFramesPerSecond = self.framesDisplayed;// % self.framesPerSecond;
		
		float newValue = (framesOutOfFramesPerSecond / (float) self.framesPerSecond);
		[drawCall.shaderProgram setValue:&newValue forUniform:uniformTimeInSecs];
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

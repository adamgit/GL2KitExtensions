#import "ViewController.h"

#import "GLKX_Library.h"

@interface ViewController ()
@end

@implementation ViewController
{
	GLKMatrix4 projectionMatrix;
}

- (void)dealloc
{
    [super dealloc];
}

-(GLK2DrawCall*) drawCallWithUnitTriangleAtOriginUsingShaders:(GLK2ShaderProgram*) shaderProgram
{
	GLK2DrawCall* dc = [[GLK2DrawCall new] autorelease];
	
	dc.shaderProgram = shaderProgram;
	
	/**   ... Make some geometry */
	
	GLfloat z = -0.0; // must be more than -1 * zNear, and ABS() less than zFar
	GLKVector3 cpuBuffer[3] = 
	{
		GLKVector3Make(-0.5,  -0.5, z),
		GLKVector3Make(-0.5, 0, z),
		GLKVector3Make( 0,  -0.5, z)
	};
	GLK2BufferObject* sharedVBOPositions = [GLK2BufferObject newVBOFilledWithData:cpuBuffer inFormat:[GLK2BufferFormat bufferFormatOneAttributeMadeOfGLFloats:3] numVertices:3 updateFrequency:GLK2BufferObjectFrequencyStatic];
	
	GLKVector2 attributesVirtualXY [3] = 
	{
		GLKVector2Make( 0, 0 ),
		GLKVector2Make( 0, 1 ),
		GLKVector2Make( 1, 0 )
	};
	GLK2BufferObject* sharedVBOVirtualXYs = [GLK2BufferObject newVBOFilledWithData:attributesVirtualXY inFormat:[GLK2BufferFormat bufferFormatOneAttributeMadeOfGLFloats:2] numVertices:3 updateFrequency:GLK2BufferObjectFrequencyStatic];
	
	GLK2Attribute* attPosition = [shaderProgram attributeNamed:@"position"]; // will fail if you haven't called glUseProgram yet
	GLK2Attribute* attXY = [shaderProgram attributeNamed:@"textureCoordinate"];
	
	dc.numVerticesToDraw = 3;
	dc.glDrawCallType = GL_TRIANGLES;
	
	dc.VAO = [[GLK2VertexArrayObject new] autorelease];
	[dc.VAO addVBO:sharedVBOPositions forAttributes:@[attPosition] numVertices:3];
	[dc.VAO addVBO:sharedVBOVirtualXYs forAttributes:@[attXY] numVertices:3];
	
	return dc;
	
}

-(GLK2DrawCall*) drawCallWithUnitCubeAtOriginUsingShaders:(GLK2ShaderProgram*) shaderProgram
{
	GLK2DrawCall* dc = [[GLK2DrawCall new] autorelease];
	
	dc.shaderProgram = shaderProgram;
	
	/**   ... Make some geometry */
	
	GLKVector3 cpuBuffer[36] = 
	{
		// bottom
		GLKVector3Make(-0.5,-0.5, -0.5),
		GLKVector3Make( 0.5, 0.5, -0.5),
		GLKVector3Make( 0.5,-0.5, -0.5),
		GLKVector3Make(-0.5,-0.5, -0.5),
		GLKVector3Make(-0.5, 0.5, -0.5),
		GLKVector3Make( 0.5, 0.5, -0.5),
		
		// top
		GLKVector3Make(-0.5,-0.5, 0.5),
		GLKVector3Make( 0.5,-0.5, 0.5),
		GLKVector3Make( 0.5, 0.5, 0.5),
		GLKVector3Make(-0.5,-0.5, 0.5),
		GLKVector3Make( 0.5, 0.5, 0.5),
		GLKVector3Make(-0.5, 0.5, 0.5),
		
		// north
		GLKVector3Make(-0.5, 0.5,-0.5),
		GLKVector3Make( 0.5, 0.5, 0.5),
		GLKVector3Make( 0.5, 0.5,-0.5),
		GLKVector3Make(-0.5, 0.5,-0.5),
		GLKVector3Make(-0.5, 0.5, 0.5),
		GLKVector3Make( 0.5, 0.5, 0.5),
		
		// south
		GLKVector3Make(-0.5, -0.5,-0.5),
		GLKVector3Make( 0.5, -0.5,-0.5),
		GLKVector3Make( 0.5, -0.5, 0.5),
		GLKVector3Make(-0.5, -0.5,-0.5),
		GLKVector3Make( 0.5, -0.5, 0.5),
		GLKVector3Make(-0.5, -0.5, 0.5),
		
		// east
		GLKVector3Make( 0.5,-0.5,-0.5),
		GLKVector3Make( 0.5, 0.5,-0.5),
		GLKVector3Make( 0.5, 0.5, 0.5),
		GLKVector3Make( 0.5,-0.5,-0.5),
		GLKVector3Make( 0.5, 0.5, 0.5),
		GLKVector3Make( 0.5,-0.5, 0.5),
		
		// west
		GLKVector3Make(-0.5,-0.5,-0.5),
		GLKVector3Make(-0.5, 0.5, 0.5),
		GLKVector3Make(-0.5, 0.5,-0.5),
		GLKVector3Make(-0.5,-0.5,-0.5),
		GLKVector3Make(-0.5,-0.5, 0.5),
		GLKVector3Make(-0.5, 0.5, 0.5),
	};
	GLK2BufferObject* sharedVBOPositions = [GLK2BufferObject newVBOFilledWithData:cpuBuffer inFormat:[GLK2BufferFormat bufferFormatOneAttributeMadeOfGLFloats:3] numVertices:36 updateFrequency:GLK2BufferObjectFrequencyStatic];
	
	GLKVector2 attributesVirtualXY [36] = 
	{
		GLKVector2Make( 0, 0 ),
		GLKVector2Make( 1, 1 ),
		GLKVector2Make( 1, 0 ),
		GLKVector2Make( 0, 0 ),
		GLKVector2Make( 0, 1 ),
		GLKVector2Make( 1, 1 ),
		
		GLKVector2Make( 0, 0 ),
		GLKVector2Make( 1, 0 ),
		GLKVector2Make( 1, 1 ),
		GLKVector2Make( 0, 0 ),
		GLKVector2Make( 1, 1 ),
		GLKVector2Make( 0, 1 ),
		
		GLKVector2Make( 0, 0 ),
		GLKVector2Make( 1, 1 ),
		GLKVector2Make( 1, 0 ),
		GLKVector2Make( 0, 0 ),
		GLKVector2Make( 0, 1 ),
		GLKVector2Make( 1, 1 ),
		
		GLKVector2Make( 0, 0 ),
		GLKVector2Make( 1, 0 ),
		GLKVector2Make( 1, 1 ),
		GLKVector2Make( 0, 0 ),
		GLKVector2Make( 1, 1 ),
		GLKVector2Make( 0, 1 ),
		
		GLKVector2Make( 0, 0 ),
		GLKVector2Make( 1, 0 ),
		GLKVector2Make( 1, 1 ),
		GLKVector2Make( 0, 0 ),
		GLKVector2Make( 1, 1 ),
		GLKVector2Make( 0, 1 ),
		
		GLKVector2Make( 0, 0 ),
		GLKVector2Make( 1, 1 ),
		GLKVector2Make( 1, 0 ),
		GLKVector2Make( 0, 0 ),
		GLKVector2Make( 0, 1 ),
		GLKVector2Make( 1, 1 ),
	};
	GLK2BufferObject* sharedVBOVirtualXYs = [GLK2BufferObject newVBOFilledWithData:attributesVirtualXY inFormat:[GLK2BufferFormat bufferFormatOneAttributeMadeOfGLFloats:2] numVertices:36 updateFrequency:GLK2BufferObjectFrequencyStatic];
	
	GLK2Attribute* attPosition = [shaderProgram attributeNamed:@"position"]; // will fail if you haven't called glUseProgram yet
	GLK2Attribute* attXY = [shaderProgram attributeNamed:@"textureCoordinate"];
	
	dc.numVerticesToDraw = 36;
	dc.glDrawCallType = GL_TRIANGLES;
	dc.VAO = [[GLK2VertexArrayObject new] autorelease];
	[dc.VAO addVBO:sharedVBOPositions forAttributes:@[attPosition] numVertices:3];
	[dc.VAO addVBO:sharedVBOVirtualXYs forAttributes:@[attXY] numVertices:3];
	
	return dc;
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
	[simpleClearingCall setClearColourRed:0.5 green:0 blue:0 alpha:1];
	[result addObject: simpleClearingCall];
	
#define TEST_ONE_TRIANGLE_AT_ORIGIN 0
#define TEST_ONE_CUBE_AT_ORIGIN 1
	
#if TEST_ONE_TRIANGLE_AT_ORIGIN
	GLK2DrawCall* dcTri = [self drawCallWithUnitTriangleAtOriginUsingShaders:
						   [GLK2ShaderProgram shaderProgramFromVertexFilename:@"VertexProjectedWithTexture" fragmentFilename:@"FragmentWithTexture"]];
	GLK2Uniform* samplerTexture1 = [dcTri.shaderProgram uniformNamed:@"s_texture1"];
	GLK2Texture* texture = [GLK2Texture textureNamed:@"tex2"];
	[dcTri setTexture:texture forSampler:samplerTexture1];
		
	[result addObject:dcTri];
#endif
	
#if TEST_ONE_CUBE_AT_ORIGIN
	GLK2DrawCall* dcCube = [self drawCallWithUnitCubeAtOriginUsingShaders:
						   [GLK2ShaderProgram shaderProgramFromVertexFilename:@"VertexProjectedWithTexture" fragmentFilename:@"FragmentWithTexture"]];
	GLK2Uniform* samplerTexture1 = [dcCube.shaderProgram uniformNamed:@"s_texture1"];
	GLK2Texture* texture = [GLK2Texture textureNamed:@"tex2"];
	[dcCube setTexture:texture forSampler:samplerTexture1];
	[result addObject:dcCube];
#endif
	
#if DSFDSFDSFDSFD
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
	GLK2BufferObject* sharedVBOPositions = [GLK2BufferObject newVBOFilledWithData:cpuBuffer inFormat:[GLK2BufferFormat bufferFormatOneAttributeMadeOfGLFloats:3] numVertices:3 updateFrequency:GLK2BufferObjectFrequencyStatic];
	
	GLKVector2 attributesVirtualXY [3] = 
	{
		GLKVector2Make( 0, 0 ),
		GLKVector2Make( 0, 1 ),
		GLKVector2Make( 1, 0 )
	};
	GLK2BufferObject* sharedVBOVirtualXYs = [GLK2BufferObject newVBOFilledWithData:attributesVirtualXY inFormat:[GLK2BufferFormat bufferFormatOneAttributeMadeOfGLFloats:2] numVertices:3 updateFrequency:GLK2BufferObjectFrequencyStatic];
	
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
#endif
	
	return result;
}

-(void)willRenderDrawCallUsingVAOShaderProgramAndDefaultUniforms:(GLK2DrawCall *)drawCall
{
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

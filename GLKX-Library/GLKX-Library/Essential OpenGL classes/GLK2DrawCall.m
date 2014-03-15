#import "GLK2DrawCall.h"

@interface GLK2DrawCall()
@property(nonatomic,retain) NSMutableArray* textureUnitSlots;
@end

@implementation GLK2DrawCall
{
	float clearColour[4];
}

+(GLK2DrawCall *)drawCallPoints
{
	GLK2DrawCall* dc = [[GLK2DrawCall new] autorelease];
	
	dc.glDrawCallType = GL_POINTS;
	
	return dc;
}
+(GLK2DrawCall *)drawCallLines
{
	GLK2DrawCall* dc = [[GLK2DrawCall new] autorelease];
	
	dc.glDrawCallType = GL_LINES;
	
	return dc;
}
+(GLK2DrawCall *)drawCallLineLoop
{
	GLK2DrawCall* dc = [[GLK2DrawCall new] autorelease];
	
	dc.glDrawCallType = GL_LINE_LOOP;
	
	return dc;
}
+(GLK2DrawCall *)drawCallLineStrip
{
	GLK2DrawCall* dc = [[GLK2DrawCall new] autorelease];
	
	dc.glDrawCallType = GL_LINE_STRIP;
	
	return dc;
}
+(GLK2DrawCall *)drawCallTriangles
{
	GLK2DrawCall* dc = [[GLK2DrawCall new] autorelease];
	
	dc.glDrawCallType = GL_TRIANGLES;
	
	return dc;
}
+(GLK2DrawCall *)drawCallTriangleFan
{
	GLK2DrawCall* dc = [[GLK2DrawCall new] autorelease];
	
	dc.glDrawCallType = GL_TRIANGLE_FAN;
	
	return dc;
}
+(GLK2DrawCall *)drawCallTriangleStrip
{
	GLK2DrawCall* dc = [[GLK2DrawCall new] autorelease];
	
	dc.glDrawCallType = GL_TRIANGLE_STRIP;
	
	return dc;
}

-(void)dealloc
{
	self.texturesFromSamplers = nil;
	self.textureUnitSlots = nil;
	self.shaderProgram = nil;
	self.VAO = nil;
	self.uniformValueGenerator = nil;
	
	NSLog(@"Drawcall dealloced: %@ (\"%@\")", [self class], self.title );
	self.title = nil;
	
	[super dealloc];
}

- (id)initWithTitle:(NSString *)title
{
	self = [super init];
	if (self) {
		self.title = title;
		
		/** Defaults different to GL defaults */
		[self setClearColourRed:1.0f green:0 blue:1.0f alpha:1.0f];
		self.requiresDepthTest = TRUE;
		self.requiresCullFace = TRUE;
		self.requiresAlphaBlending = FALSE;
		
		/** Sensible defaults even for modes that are off by default */
		self.alphaBlendSourceFactor = GL_ONE;
		self.alphaBlendDestinationFactor = GL_ONE_MINUS_SRC_ALPHA;
		
		/** General class setup */
		self.texturesFromSamplers = [NSMutableDictionary dictionary];
		
		GLint sizeOfTextureUnitSlotsArray; // MUST be fixed size, and have an entry for every index!
		glGetIntegerv( GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS, &sizeOfTextureUnitSlotsArray );
		self.textureUnitSlots = [NSMutableArray arrayWithCapacity:sizeOfTextureUnitSlotsArray];
		for( int i=0; i<sizeOfTextureUnitSlotsArray; i++ )
			[self.textureUnitSlots addObject:[NSNull null]]; // marks this slto as "currently empty"
	}
	return self;
}

- (id)init
{
	return [self initWithTitle:[NSString stringWithFormat:@"Drawcall-%i", arc4random_uniform(INT_MAX)]];
}

-(NSString *)description
{
	return self.title;
}

#pragma mark - glClear

-(float*) clearColourArray
{
	return &clearColour[0];
}

-(void) setClearColourRed:(float) r green:(float) g blue:(float) b alpha:(float) a
{
	clearColour[0] = r;
	clearColour[1] = g;
	clearColour[2] = b;
	clearColour[3] = a;
}

#pragma mark - Shader Uniforms

-(void) setAllUniformValuesForShader
{
	if( self.uniformValueGenerator == nil )
	{
		if( [self.shaderProgram allUniforms].count > 0 )
		{
			NSLog(@"WARNING: DrawCall '%@' has uniforms, but no uniformValueGenerator; if another object ever uses the same ShaderProgram, and changes the values, this DrawCall will get 'leaked' incorrect values. Set a .uniformValueGenerator to remove this message - even an empty one that returns false for everything.", self.title );
		}
	}
	else
	{
		for( GLK2Uniform* uniform in [self.shaderProgram allUniforms] )
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
							GLKMatrix2* matrixValue = [self.uniformValueGenerator matrix2ForUniform:uniform inDrawCall:self];
							floatPointer = matrixValue->m;
						}break;
						case 3:
						{
							GLKMatrix3* matrixValue = [self.uniformValueGenerator matrix3ForUniform:uniform inDrawCall:self];
							floatPointer = matrixValue->m;
						}break;
						case 4:
						{
							GLKMatrix4* matrixValue = [self.uniformValueGenerator matrix4ForUniform:uniform inDrawCall:self];
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
							GLKVector2* vectorValue = [self.uniformValueGenerator vector2ForUniform:uniform inDrawCall:self];
							floatPointer = vectorValue->v;
						}break;
						case 3:
						{
							GLKVector3* vectorValue = [self.uniformValueGenerator vector3ForUniform:uniform inDrawCall:self];
							floatPointer = vectorValue->v;
						}break;
						case 4:
						{
							GLKVector4* vectorValue = [self.uniformValueGenerator vector4ForUniform:uniform inDrawCall:self];
							floatPointer = vectorValue->v;
						}break;
					}
				}
				else
				{
					if( ! [self.uniformValueGenerator floatForUniform:uniform returnIn:floatPointer inDrawCall:self] )
						floatPointer = 0; // kill the pointer
				}
				
				if( floatPointer != NULL ) // prevent the next line from clobbering the value!
					[self.shaderProgram setValue:floatPointer forUniform:uniform];
			}
			else
			{
				int tempInt;
				if( uniform.isVector )
				{
					NSAssert(FALSE, @"Int vectors not supported yet");
				}
				else
				{
					if( [self.uniformValueGenerator intForUniform:uniform returnIn:&tempInt inDrawCall:self] )
						[self.shaderProgram setValue:&tempInt forUniform:uniform];
					else
						; // don't change anything; the generator had no value for this uniform
				}
				
			}
		}
	}
	
}

#pragma mark - textures

/**
 This method is long and convoluted, hence needs explanation. The short answer is "textures in OpenGL are FUBAR,
 they are a quick hack that was shoved into OpenGL in the 1990's, and break every rule of OpenGL APIs. Deal with it".
 
 Longer answer:
 
 In modern OpenGL (GL ES 2+), to use a texture, you MUST have a ShaderProgram, and have the shaderprogram "use" it.
 
 For a ShaderProgram to use a texture, in GL ES 2, you MUST do:
  1. Load your textures onto GPU (standard OpenGL: use glBindTexture + glTex2D as normal)
  2. Choose a texture-unit for each texture that the ShaderProgram will read
  3. For each texture in the ShaderProgram, find the magic "sampler2d" variable (it's technically a "uniform" but with a different type-name)
  4. ...and set the "value" of that uniform/sampler2d to "the texture-unit I chose in 2. above" (NOTE: this fundamentally conflicts with what "uniform" means in Shaders, hence the rename)
 
  5. EVERY TIME YOU RENDER A FRAME: you have to call "glActiveTexture( the texture-unit )" and "glBindTexture( GL_TEXTURE_2D, texturename )" for each texture you configured in 1-4 above
  6. You must NEVER try to use more than GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS texture-units; that's the limit of how many textures the hardware can use in a single ShaderProgram
 
 So, in summary, this class will have to store:
  - GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS * textureunit "slots"
  - each sampler2d in the shader-source needs to be "mapped" to a specific slot (and remembered)
  - on each render, for each sampler2d, retrieve the "texture" and the "texture-slot" and use them
 
 BUT: you cannot simply use NSArray to store the textureunit slots / samplers, because removing a sampler would change the
 index of the other samplers, and break everything. So ... we use a C array.
 */
-(GLuint)setTexture:(GLK2Texture *)texture forSampler:(GLK2Uniform *)sampler
{
	NSAssert( sampler != nil, @"Cannot set a texture for non-existent sampler = nil");
	
	if( texture != nil )
	{
		/** do we already have this sampler stored? */
		int indexOfStoredSampler = -1;
		int i=-1;
		for( GLK2Uniform* samplerInUnitSlot in self.textureUnitSlots )
		{
			i++;
			
			if( (id)samplerInUnitSlot != [NSNull null] && [samplerInUnitSlot isEqual:sampler])
			{
				indexOfStoredSampler = i;
				break;
			}
		}
		
		/** store the texture locally */
		[self.texturesFromSamplers setObject:texture forKey:sampler];
		
		/** choose a textureunit slot, if not already assigned for that sampler */
		if( indexOfStoredSampler < 0 )
		{
			i = -1;
			for( GLK2Uniform* samplerInUnitSlot in self.textureUnitSlots )
			{
				i++;
				
				if( (id)samplerInUnitSlot == [NSNull null])
				{
					[self.textureUnitSlots replaceObjectAtIndex:i withObject:sampler];
					indexOfStoredSampler = i;
					
					/** Inform the embedded shader program that this slot is the new source for this sampler */
					// save the current program, if it's not ours:
					GLint currentProgram;
					glGetIntegerv( GL_CURRENT_PROGRAM, &currentProgram);
					
					NSAssert( self.shaderProgram != nil, @"Cannot set textures on a drawcall until you've given it a shader program (it's possible, but not implemented here)");
					GLint textureUnitOffsetOpenGLMakesThisHard = [self textureUnitOffsetForSampler:sampler];
					[self.shaderProgram setValueOutsideRenderLoopRestoringProgramAfterwards:&textureUnitOffsetOpenGLMakesThisHard forUniform:sampler];
					break;
				}
			}
			
			NSAssert( indexOfStoredSampler >= 0, @"Ran out of texture-units; you cannot assign this many texture samplers to a single ShaderProgram on your hardware" );
		}
		
		return indexOfStoredSampler;
	}
	else
	{
		[self.texturesFromSamplers removeObjectForKey:sampler];
		
		int i=-1;
		for( GLK2Uniform* samplerInUnitSlot in self.textureUnitSlots )
		{
			i++;
			
			if( (id)samplerInUnitSlot != [NSNull null] && [samplerInUnitSlot isEqual:sampler])
			{
				[self.textureUnitSlots replaceObjectAtIndex:i withObject:[NSNull null]];
				break;
			}
		}
		
		return -1;
	}
}

-(GLuint)setTexture:(GLK2Texture *)texture forSamplerNamed:(NSString *)samplerName
{
	NSAssert( self.shaderProgram != nil, @"Cannot set textures on a drawcall until you've given it a shader program");
	
	GLK2Uniform* sampler = [self.shaderProgram uniformNamed:samplerName];
	NSAssert( sampler != nil, @"Unknown sampler named %@", samplerName );
	
	return [self setTexture:texture forSampler:sampler];
}

-(GLK2Texture*)getTextureForSamplerNamed:(NSString *)samplerName
{
	NSAssert( self.shaderProgram != nil, @"Cannot get textures from a drawcall until you've given it a shader program");
	
	GLK2Uniform* sampler = [self.shaderProgram uniformNamed:samplerName];
	NSAssert( sampler != nil, @"Unknown sampler named %@", samplerName );
	
	return [self.texturesFromSamplers objectForKey:sampler];
}

-(GLint)textureUnitOffsetForSampler:(GLK2Uniform *)sampler
{
	int i=-1;
	for( GLK2Uniform* samplerInUnitSlot in self.textureUnitSlots )
	{
		i++;
		
		if( (id)samplerInUnitSlot != [NSNull null] && [samplerInUnitSlot isEqual:sampler])
		{
			return i; // NB: sometimes you need i, sometimes you need GL_TEXTURE0 + i. OpenGL API is evil. Don't mix them up!
		}
	}
	
	return -1;
}

#pragma mark - workaround for bad OpenGL committee decisions

-(void) reCreateVAOOnCurrentThread
{
	GLK2VertexArrayObject* newVAO;
	
	/** this is the important bit! */
	newVAO = [[[GLK2VertexArrayObject alloc] init] autorelease];
	
	/** ... and copy across the VBOs ... */
	for( GLK2BufferObject* vbo in self.VAO.VBOs )
	{
		[newVAO addVBO:vbo forAttributes:[self.VAO attributesArrayForVBO:vbo]];
	}
	
	self.VAO = newVAO;
}

-(id) copyDrawCallAllocatingNewVAO
{
	GLK2DrawCall* newCopy = [[[self class] alloc] init];
	
	newCopy.title = self.title;
	
	[newCopy setClearColourRed:self.clearColourArray[0] green:self.clearColourArray[1] blue:self.clearColourArray[2] alpha:self.clearColourArray[3]];
	
	newCopy.shouldClearColorBit = self.shouldClearColorBit;
	newCopy.shouldClearDepthBit = self.shouldClearDepthBit;
	
	newCopy.shaderProgram = self.shaderProgram;
	
	newCopy.requiresDepthTest = self.requiresDepthTest;
	
	newCopy.requiresCullFace = self.requiresCullFace;
	
	newCopy.requiresAlphaBlending = self.requiresAlphaBlending;
	
	newCopy.alphaBlendSourceFactor = self.alphaBlendSourceFactor;
	newCopy.alphaBlendDestinationFactor = self.alphaBlendDestinationFactor;
	
	/** this is the important bit! */
	newCopy.VAO = [[[GLK2VertexArrayObject alloc] init] autorelease];
	
	/** ... and copy across the VBOs ... */
	for( GLK2BufferObject* vbo in self.VAO.VBOs )
	{
		[newCopy.VAO addVBO:vbo forAttributes:[self.VAO attributesArrayForVBO:vbo]];
	}
	
	newCopy.glDrawCallType = self.glDrawCallType;
	
	newCopy.numVerticesToDraw = self.numVerticesToDraw;
	
	newCopy.uniformValueGenerator = self.uniformValueGenerator;
	
	for( GLK2Uniform* sampler in self.texturesFromSamplers.allKeys )
	{
		GLK2Texture* texture = [self.texturesFromSamplers objectForKey:sampler];
		
		[newCopy setTexture:texture forSampler:sampler];
	}
	
	return newCopy;
}

@end

#import "GLK2DrawCall.h"

@interface GLK2DrawCall()
@property(nonatomic,retain) NSMutableArray* textureUnitSlots;
@end

@implementation GLK2DrawCall
{
	float clearColour[4];
}

-(void)dealloc
{
	self.texturesFromSamplers = nil;
	self.textureUnitSlots = nil;
	
	[super dealloc];
}

- (id)init
{
	self = [super init];
	if (self) {
		[self setClearColourRed:1.0f green:0 blue:1.0f alpha:1.0f];
		
		self.texturesFromSamplers = [NSMutableDictionary dictionary];
		
		GLint sizeOfTextureUnitSlotsArray; // MUST be fixed size, and have an entry for every index!
		glGetIntegerv( GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS, &sizeOfTextureUnitSlotsArray );
		self.textureUnitSlots = [NSMutableArray arrayWithCapacity:sizeOfTextureUnitSlotsArray];
		for( int i=0; i<sizeOfTextureUnitSlotsArray; i++ )
			[self.textureUnitSlots addObject:[NSNull null]]; // marks this slto as "currently empty"
	}
	return self;
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
					glUseProgram(self.shaderProgram.glName);
					glUniform1i( sampler.glLocation, [self textureUnitOffsetForSampler:sampler] );
					// Or, alternatively (identically): [self.shaderProgram setValue:[self textureUnitOffsetForSampler:sampler] forUniform:sampler];
					
					// restore the current program, if it's wasn't ours:
					glUseProgram(currentProgram);
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
	return [self setTexture:texture forSampler:[self.shaderProgram uniformNamed:samplerName]];
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
@end

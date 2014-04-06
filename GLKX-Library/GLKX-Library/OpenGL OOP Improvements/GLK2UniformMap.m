#import "GLK2UniformMap.h"

#import "GLK2Uniform.h"

@interface GLK2UniformMap ()
@property(nonatomic,retain) NSMutableArray* namesOfMatrix2s, * namesOfMatrix3s, * namesOfMatrix4s;
@property(nonatomic,retain) NSMutableArray* namesOfVector2s, * namesOfVector3s, * namesOfVector4s;
@property(nonatomic,retain) NSMutableArray* namesOfInts;
@property(nonatomic,retain) NSMutableArray* namesOfFloats;
@end

@implementation GLK2UniformMap
{
	GLKMatrix2* rawMatrix2s;
	GLKMatrix3* rawMatrix3s;
	GLKMatrix4* rawMatrix4s;
	BOOL* existsRawMatrix2, * existsRawMatrix3, * existsRawMatrix4;
	int countOfMatrix2s, countOfMatrix3s, countOfMatrix4s;
	
	GLKVector2* rawVector2s;
	GLKVector3* rawVector3s;
	GLKVector4* rawVector4s;
	BOOL* existsRawVector2, * existsRawVector3, * existsRawVector4;
	int countOfVector2s, countOfVector3s, countOfVector4s;
	
	GLint* rawInts;
	BOOL* existsRawInt;
	int countOfInts;
	
	GLfloat* rawFloats;
	BOOL* existsRawFloat;
	int countOfFloats;
}

+(GLK2UniformMap *)uniformMapForLinkedShaderProgram:(GLK2ShaderProgram *)shaderProgram
{
	NSAssert(shaderProgram.status == GLK2ShaderProgramStatusLinked, @"Expected a linked shaderProgram. Could be OK without, if you pre-filled the Uniforms array - but that's very unlikely");
	
	GLK2UniformMap* newValue = [[[GLK2UniformMap alloc] initWithUniforms:shaderProgram.allUniforms] autorelease];
	
	return newValue;
}

-(void)dealloc
{
	free( rawMatrix2s );
	free( rawMatrix3s );
	free( rawMatrix4s );
	free( existsRawMatrix2 );
	free( existsRawMatrix3 );
	free( existsRawMatrix4 );
	
	free( rawVector2s );
	free( rawVector3s );
	free( rawVector4s );
	free( existsRawVector2 );
	free( existsRawVector3 );
	free( existsRawVector4 );
	
	free( rawInts );
	free( existsRawInt );
	
	free( rawFloats );
	free( existsRawFloat );
	
	self.namesOfMatrix2s = self.namesOfMatrix3s = self.namesOfMatrix4s = nil;
	self.namesOfVector2s = self.namesOfVector3s = self.namesOfVector4s = nil;
	self.namesOfInts = nil;
	self.namesOfFloats = nil;
	
	[super dealloc];
}

- (id)initWithUniforms:(NSArray*) allUniforms
{
    self = [super init];
    if (self) {
        for( GLK2Uniform* uniform in allUniforms )
		{			
			if( uniform.isMatrix )
			{
				NSAssert( uniform.arrayLength == 1, @"Not supported: uniform that is an array-of-matrices");
				switch( uniform.matrixWidth )
				{
					case 2:
						countOfMatrix2s++;
						break;
					case 3:
						countOfMatrix3s++;
						break;
					case 4:
						countOfMatrix4s++;
						break;
				}
			}
			else if( uniform.isVector )
			{
				NSAssert( uniform.arrayLength == 1, @"Not supported: uniform that is an array-of-vectors");
				switch( uniform.vectorWidth )
				{
					case 2:
						countOfVector2s++;
						break;
					case 3:
						countOfVector3s++;
						break;
					case 4:
						countOfVector4s++;
						break;
				}
			}
			else
			{
				// FIXME: not supported yet - raw bools, shorts, etc
				if( uniform.isInteger )
				{
					countOfInts++;
				}
				else if( uniform.isFloat )
				{
					countOfFloats++;
				}
			}
		}
		
		/** Now allocate + fill */
		rawMatrix2s = calloc( countOfMatrix2s, sizeof(GLKMatrix2));
		rawMatrix3s = calloc( countOfMatrix3s, sizeof(GLKMatrix3));
		rawMatrix4s = calloc( countOfMatrix4s, sizeof(GLKMatrix4));
		existsRawMatrix2 = calloc( countOfMatrix2s, sizeof(BOOL));
		existsRawMatrix3 = calloc( countOfMatrix3s, sizeof(BOOL));
		existsRawMatrix4 = calloc( countOfMatrix4s, sizeof(BOOL));
		self.namesOfMatrix2s = [NSMutableArray array];
		self.namesOfMatrix3s = [NSMutableArray array];
		self.namesOfMatrix4s = [NSMutableArray array];
		
		rawVector2s = calloc( countOfVector2s, sizeof(GLKMatrix2));
		rawVector3s = calloc( countOfVector3s, sizeof(GLKMatrix3));
		rawVector4s = calloc( countOfVector4s, sizeof(GLKMatrix4));
		existsRawVector2 = calloc( countOfVector2s, sizeof(BOOL));
		existsRawVector3 = calloc( countOfVector3s, sizeof(BOOL));
		existsRawVector4 = calloc( countOfVector4s, sizeof(BOOL));
		self.namesOfVector2s = [NSMutableArray array];
		self.namesOfVector3s = [NSMutableArray array];
		self.namesOfVector4s = [NSMutableArray array];
		
		rawInts = calloc( countOfInts, sizeof(GLint));
		existsRawInt = calloc( countOfInts, sizeof(BOOL));
		self.namesOfInts = [NSMutableArray array];
		
		rawFloats = calloc( countOfFloats, sizeof(GLfloat));
		existsRawFloat = calloc( countOfFloats, sizeof(BOOL));
		self.namesOfFloats = [NSMutableArray array];
		
		for( GLK2Uniform* uniform in allUniforms )
		{
			if( uniform.isMatrix )
			{
				switch( uniform.matrixWidth )
				{
					case 2:
						[self.namesOfMatrix2s addObject:uniform.nameInSourceFile];
						break;
					case 3:
						[self.namesOfMatrix3s addObject:uniform.nameInSourceFile];
						break;
					case 4:
						[self.namesOfMatrix4s addObject:uniform.nameInSourceFile];
						break;
				}
			}
			else if( uniform.isVector )
			{
				switch( uniform.vectorWidth )
				{
					case 2:
						[self.namesOfVector2s addObject:uniform.nameInSourceFile];
						break;
					case 3:
						[self.namesOfVector3s addObject:uniform.nameInSourceFile];
						break;
					case 4:
						[self.namesOfVector4s addObject:uniform.nameInSourceFile];
						break;
				}
			}
			else
			{
				// FIXME: add bools etc
				if( uniform.isInteger )
				{
					[self.namesOfInts addObject:uniform.nameInSourceFile];
				}
				else if( uniform.isFloat )
				{
					[self.namesOfFloats addObject:uniform.nameInSourceFile];
				}
			}
		}
    }
    return self;
}

-(NSString *)description
{
	NSMutableString* s = [[NSMutableString new] autorelease];
	
	if( countOfInts > 0 )
	{
		int index = -1;
		for( NSString* name in self.namesOfInts )
		{
			index++;
			[s appendFormat:@"GLint: %@ ", name];
			if( existsRawInt[index] )
				[s appendFormat:@"%i", rawInts[index]];
			else
				[s appendString:@"<missing>"];
			[s appendString:@"\n"];
		}
	}
	if( countOfFloats > 0 )
	{
		int floatIndex = -1;
		for( NSString* name in self.namesOfFloats )
		{
			floatIndex++;
			[s appendFormat:@"GLfloat: %@ ", name];
			if( existsRawFloat[floatIndex] )
				[s appendFormat:@"%.3f", rawFloats[floatIndex]];
			else
				[s appendString:@"<missing>"];
			[s appendString:@"\n"];
		}
	}
	if( countOfVector2s > 0 )
	{
		int index = -1;
		for( NSString* name in self.namesOfVector2s )
		{
			index++;
			[s appendFormat:@"Vector2: %@ ", name];
			if( existsRawVector2[index] )
				[s appendFormat:@"%@", NSStringFromGLKVector2( rawVector2s[index] )];
			else
				[s appendString:@"<missing>"];
			[s appendString:@"\n"];
		}
	}
	if( countOfVector3s > 0 )
	{
		int index = -1;
		for( NSString* name in self.namesOfVector3s )
		{
			index++;
			[s appendFormat:@"Vector3: %@ ", name];
			if( existsRawVector3[index] )
				[s appendFormat:@"%@", NSStringFromGLKVector3( rawVector3s[index] )];
			else
				[s appendString:@"<missing>"];
			[s appendString:@"\n"];
		}
	}
	if( countOfVector4s > 0 )
	{
		int index = -1;
		for( NSString* name in self.namesOfVector4s )
		{
			index++;
			[s appendFormat:@"Vector4: %@ ", name];
			if( existsRawVector4[index] )
				[s appendFormat:@"%@", NSStringFromGLKVector4( rawVector4s[index] )];
			else
				[s appendString:@"<missing>"];
			[s appendString:@"\n"];
		}
	}
	
	if( countOfMatrix2s > 0 )
	{
		int index = -1;
		for( NSString* name in self.namesOfMatrix2s )
		{
			index++;
			[s appendFormat:@"Matrix2: %@ ", name];
			if( existsRawMatrix2[index] )
				[s appendFormat:@"%@", NSStringFromGLKMatrix2( rawMatrix2s[index] )];
			else
				[s appendString:@"<missing>"];
			[s appendString:@"\n"];
		}
	}
	if( countOfMatrix3s > 0 )
	{
		int index = -1;
		for( NSString* name in self.namesOfMatrix3s )
		{
			index++;
			[s appendFormat:@"Matrix3: %@ ", name];
			if( existsRawMatrix3[index] )
				[s appendFormat:@"%@", NSStringFromGLKMatrix3( rawMatrix3s[index] )];
			else
				[s appendString:@"<missing>"];
			[s appendString:@"\n"];
		}
	}
	if( countOfMatrix4s > 0 )
	{
		int index = -1;
		for( NSString* name in self.namesOfMatrix4s )
		{
			index++;
			[s appendFormat:@"Matrix4: %@ ", name];
			if( existsRawMatrix4[index] )
				[s appendFormat:@"%@", NSStringFromGLKMatrix4( rawMatrix4s[index] )];
			else
				[s appendString:@"<missing>"];
			[s appendString:@"\n"];
		}
	}
	
	if( s.length < 1 )
		[s appendString:@"<Generator created with no uniforms; cannot hold any data>"];
	
	return s;
}

#pragma mark - Matrices

-(GLKMatrix2*) pointerToMatrix2Named:(NSString*) name
{
	NSUInteger rowIndex = [self.namesOfMatrix2s indexOfObject:name];
	if( rowIndex == NSNotFound )
		return NULL;
	
	if( ! existsRawMatrix2[rowIndex] )
		return NULL;
	
	return &rawMatrix2s[rowIndex];
}
-(GLKMatrix3*) pointerToMatrix3Named:(NSString*) name
{
	NSUInteger rowIndex = [self.namesOfMatrix3s indexOfObject:name];
	if( rowIndex == NSNotFound )
		return NULL;
	
	if( ! existsRawMatrix3[rowIndex] )
		return NULL;
	
	return &rawMatrix3s[rowIndex];
}
-(GLKMatrix4*) pointerToMatrix4Named:(NSString*) name
{
	NSUInteger rowIndex = [self.namesOfMatrix4s indexOfObject:name];
	if( rowIndex == NSNotFound )
		return NULL;
	
	if( ! existsRawMatrix4[rowIndex] )
		return NULL;
	
	return &rawMatrix4s[rowIndex];
}

-(void) setMatrix2:(GLKMatrix2) value named:(NSString*) name
{
	NSUInteger rowIndex = [self.namesOfMatrix2s indexOfObject:name];
	if( rowIndex == NSNotFound )
	{
#if LOG_WARNINGS_ON_MISSING_UNIFORMS
		NSLog(@"WARNING: attempted to setMatrix2: for non-existent uniform = %@", name );
#endif
		return;
	}
	
	existsRawMatrix2[rowIndex] = TRUE;
	rawMatrix2s[rowIndex] = value;
}
-(void) setMatrix3:(GLKMatrix3) value named:(NSString*) name
{
	NSUInteger rowIndex = [self.namesOfMatrix3s indexOfObject:name];
	if( rowIndex == NSNotFound )
	{
#if LOG_WARNINGS_ON_MISSING_UNIFORMS
		NSLog(@"WARNING: attempted to setMatrix3: for non-existent uniform = %@", name );
#endif
		return;
	}
	
	existsRawMatrix3[rowIndex] = TRUE;
	rawMatrix3s[rowIndex] = value;
}
-(void) setMatrix4:(GLKMatrix4) value named:(NSString*) name
{
	NSUInteger rowIndex = [self.namesOfMatrix4s indexOfObject:name];
	if( rowIndex == NSNotFound )
	{
#if LOG_WARNINGS_ON_MISSING_UNIFORMS
		NSLog(@"WARNING: attempted to setMatrix4: for non-existent uniform = %@", name );
#endif
		return;
	}
	
	existsRawMatrix4[rowIndex] = TRUE;
	rawMatrix4s[rowIndex] = value;
}

#pragma mark - Vectors

-(GLKVector2*) pointerToVector2Named:(NSString*) name
{
	NSUInteger rowIndex = [self.namesOfVector2s indexOfObject:name];
	if( rowIndex == NSNotFound )
		return NULL;
	
	if( ! existsRawVector2[rowIndex] )
		return NULL;
	
	return &rawVector2s[rowIndex];
}
-(GLKVector3*) pointerToVector3Named:(NSString*) name
{
	NSUInteger rowIndex = [self.namesOfVector3s indexOfObject:name];
	if( rowIndex == NSNotFound )
		return NULL;
	
	if( ! existsRawVector3[rowIndex] )
		return NULL;
	
	return &rawVector3s[rowIndex];
}
-(GLKVector4*) pointerToVector4Named:(NSString*) name
{
	NSUInteger rowIndex = [self.namesOfVector4s indexOfObject:name];
	if( rowIndex == NSNotFound )
		return NULL;
	
	if( ! existsRawVector4[rowIndex] )
		return NULL;
	
	return &rawVector4s[rowIndex];
}

-(void) setVector2:(GLKVector2) value named:(NSString*) name
{
	NSUInteger rowIndex = [self.namesOfVector2s indexOfObject:name];
	if( rowIndex == NSNotFound )
	{
#if LOG_WARNINGS_ON_MISSING_UNIFORMS
		NSLog(@"WARNING: attempted to setVector2: for non-existent uniform = %@", name );
#endif
		return;
	}
	
	existsRawVector2[rowIndex] = TRUE;
	rawVector2s[rowIndex] = value;
}
-(void) setVector3:(GLKVector3) value named:(NSString*) name
{
	NSUInteger rowIndex = [self.namesOfVector3s indexOfObject:name];
	if( rowIndex == NSNotFound )
	{
#if LOG_WARNINGS_ON_MISSING_UNIFORMS
		NSLog(@"WARNING: attempted to setVector3: for non-existent uniform = %@", name );
#endif
		return;
	}
	
	existsRawVector3[rowIndex] = TRUE;
	rawVector3s[rowIndex] = value;
}
-(void) setVector4:(GLKVector4) value named:(NSString*) name
{
	NSUInteger rowIndex = [self.namesOfVector4s indexOfObject:name];
	if( rowIndex == NSNotFound )
	{
#if LOG_WARNINGS_ON_MISSING_UNIFORMS
		NSLog(@"WARNING: attempted to setVector4: for non-existent uniform = %@", name );
#endif
		return;
	}
	
	existsRawVector4[rowIndex] = TRUE;
	rawVector4s[rowIndex] = value;
}

#pragma mark - Primitives

-(GLint*) pointerToIntNamed:(NSString*) name isValid:(BOOL*) isValid
{
	NSUInteger rowIndex = [self.namesOfInts indexOfObject:name];
	
	if( rowIndex == NSNotFound
	|| (! existsRawInt[rowIndex]) )
		*isValid = FALSE;
	else
		*isValid = TRUE;
	
	return &rawInts[rowIndex];
}

-(GLfloat*) pointerToFloatNamed:(NSString*) name isValid:(BOOL*) isValid
{
	NSUInteger rowIndex = [self.namesOfFloats indexOfObject:name];
	
	if( rowIndex == NSNotFound
	   || (! existsRawFloat[rowIndex]) )
		*isValid = FALSE;
	else
		*isValid = TRUE;
	
	return &rawFloats[rowIndex];
}

@end

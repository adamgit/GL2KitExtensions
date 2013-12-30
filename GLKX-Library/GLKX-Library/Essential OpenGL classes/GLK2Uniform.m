#import "GLK2Uniform.h"

@implementation GLK2Uniform

+(GLK2Uniform *)uniformNamed:(NSString *)nameOfUniform GLType:(GLenum)openGLType GLLocation:(GLint)openGLLocation numElementsInArray:(GLint)numElements
{
	GLK2Uniform* newValue = [[GLK2Uniform new] autorelease];
	
	newValue.nameInSourceFile = nameOfUniform;
	newValue.glType = openGLType;
	newValue.glLocation = openGLLocation;
	newValue.arrayLength = numElements;
	/****** NB: if you add any properties, make sure you add them to "copyWithZone:" method too */
	/****** NB: if you add any properties, make sure you add them to "isEqual:" method too */
	
	return newValue;
}

#pragma mark - Interpretation of OpenGL's badly-typed "type" feature

-(BOOL)isInteger
{
	switch( self.glType )
	{
		case GL_INT:
		case GL_INT_VEC2:
		case GL_INT_VEC3:
		case GL_INT_VEC4:
			return TRUE;
			
		default:
			return FALSE;
	}
}

-(BOOL)isFloat
{
	switch( self.glType )
	{
		case GL_FLOAT:
		case GL_FLOAT_VEC2:
		case GL_FLOAT_VEC3:
		case GL_FLOAT_VEC4:
		case GL_FLOAT_MAT2:
		case GL_FLOAT_MAT3:
		case GL_FLOAT_MAT4:
			return TRUE;
			
		default:
			return FALSE;
	}
}

-(BOOL)isMatrix
{
	switch( self.glType )
	{
		case GL_FLOAT_MAT2:
		case GL_FLOAT_MAT3:
		case GL_FLOAT_MAT4:
			return TRUE;
			
		default:
			return FALSE;
	}
}

-(BOOL)isVector
{
	switch( self.glType )
	{
		case GL_FLOAT_VEC2:
		case GL_FLOAT_VEC3:
		case GL_FLOAT_VEC4:
		case GL_INT_VEC2:
		case GL_INT_VEC3:
		case GL_INT_VEC4:
			return TRUE;
			
		default:
			return FALSE;
	}
}

-(int)vectorWidth
{
	switch( self.glType )
	{
		case GL_INT_VEC2:
		case GL_FLOAT_VEC2:
			return 2;
		case GL_INT_VEC3:
		case GL_FLOAT_VEC3:
			return 3;
		case GL_INT_VEC4:
		case GL_FLOAT_VEC4:
			return 4;
			
		default:
			return 0;
	}
}

-(int)matrixWidth
{
	switch( self.glType )
	{
		case GL_FLOAT_MAT2:
			return 2;
		case GL_FLOAT_MAT3:
			return 3;
		case GL_FLOAT_MAT4:
			return 4;
			
		default:
			return 0;
	}
}

-(NSString *)description
{
	return [NSString stringWithFormat:@"<GLK2Uniform:\"%@\" @ %i: %@%@>", self.nameInSourceFile, self.glLocation, self.isVector? [NSString stringWithFormat:@"vec%i", self.vectorWidth] : self.isMatrix? [NSString stringWithFormat:@"mat%i", self.matrixWidth] : self.isFloat? @"float" : self.isInteger? @"int" : @"unknown type", self.arrayLength<2? @"" : [NSString stringWithFormat:@" (%i array elements)", self.arrayLength]  ];
}

#pragma mark - methods Apple requires us to implement to use this as a key in an NSDictionary

-(id)copyWithZone:(NSZone *)zone
{
	GLK2Uniform* newCopy = [[GLK2Uniform allocWithZone:zone] init];
	
	newCopy.nameInSourceFile = self.nameInSourceFile;
	newCopy.glType = self.glType;
	newCopy.glLocation = self.glLocation;
	newCopy.arrayLength = self.arrayLength;
	
	return newCopy;
}

-(BOOL)isEqual:(id)object
{
	/** 
	 WARNING! Because we overrode this, we MUST override hash too!
	 
	 Apple's default implementation of "hash" silently breaks if you don't
	 overwrite it :( :( :( :(. Very bad design.
	 */
	if( [object class] != [self class] )
		return FALSE;
	
	GLK2Uniform* other = (GLK2Uniform*) object;
	
	return other.glLocation == self.glLocation
	&& other.glType == self.glType
	&& other.arrayLength == self.arrayLength
	&& [other.nameInSourceFile isEqualToString:self.nameInSourceFile];
}

-(NSUInteger)hash
{
	return [self.nameInSourceFile hash]; // very closely corresponds to the bucket/hash we would choose to use anyway
}

@end

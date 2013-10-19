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

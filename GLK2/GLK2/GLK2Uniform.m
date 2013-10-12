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
	
	return newValue;
}

-(id)copyWithZone:(NSZone *)zone
{
	GLK2Uniform* newCopy = [[GLK2Uniform allocWithZone:zone] init];
	
	newCopy.nameInSourceFile = self.nameInSourceFile;
	newCopy.glType = self.glType;
	newCopy.glLocation = self.glLocation;
	newCopy.arrayLength = self.arrayLength;
	
	return newCopy;
}
@end

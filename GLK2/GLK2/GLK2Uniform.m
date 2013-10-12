#import "GLK2Uniform.h"

@implementation GLK2Uniform

+(GLK2Uniform *)uniformNamed:(NSString *)nameOfUniform GLType:(GLenum)openGLType GLLocation:(GLint)openGLLocation numElementsInArray:(GLint)numElements
{
	GLK2Uniform* newValue = [[GLK2Uniform new] autorelease];
	
	newValue.nameInSourceFile = nameOfUniform;
	newValue.glType = openGLType;
	newValue.glLocation = openGLLocation;
	newValue.arrayLength = numElements;
	
	return newValue;
}

@end

/**
 Part 3: ... not published yet ...
*/
#import "GLK2Attribute.h"

@implementation GLK2Attribute


+(GLK2Attribute*) attributeNamed:(NSString*) nameOfAttribute GLType:(GLenum) openGLType GLLocation:(GLint) openGLLocation GLSize:(GLint) openGLSize
{
	GLK2Attribute* newValue = [[GLK2Attribute new] autorelease];
	
	newValue.nameInSourceFile = nameOfAttribute;
	newValue.glType = openGLType;
	newValue.glLocation = openGLLocation;
	newValue.glSize = openGLSize;
	
	return newValue;
}

@end

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
	/****** NB: if you add any properties, make sure you add them to "isEqual:" method too */
	
	return newValue;
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
	
	GLK2Attribute* other = (GLK2Attribute*) object;
	
	return other.glLocation == self.glLocation
	&& other.glType == self.glType
	&& [other.nameInSourceFile isEqualToString:self.nameInSourceFile];
}

-(NSUInteger)hash
{
	return [self.nameInSourceFile hash]; // very closely corresponds to the bucket/hash we would choose to use anyway
}
@end

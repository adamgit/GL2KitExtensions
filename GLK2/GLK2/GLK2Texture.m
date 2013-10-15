/**
 
 */
#import "GLK2Texture.h"

@interface GLK2Texture()
@property(nonatomic, readwrite) GLuint glName;
@end

@implementation GLK2Texture

+(GLK2Texture *)texturePreLoadedByApplesGLKit:(GLKTextureInfo *)appleMetadata
{
	GLK2Texture* newValue = [[[GLK2Texture alloc] initWithName:appleMetadata.name] autorelease];
	
	return newValue;
}

- (id)init
{
	GLuint newName;
	glGenTextures(1, &newName);
	
	return [self initWithName:newName];
}

- (id)initWithName:(GLuint) name
{
    self = [super init];
    if (self) {
        self.glName = name;
    }
    return self;
}

@end

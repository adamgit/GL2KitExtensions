/**
 
 */
#import "GLK2Texture.h"

#import "GLK2TextureLoaderPVRv1.h" // for textureNamed: auto-loading PVR's without Apple's bug

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

- (void)dealloc
{
	NSLog(@"Dealloc: %@, glDeleteTexures( 1, %i)", [self class], self.glName );
    glDeleteTextures(1, &_glName);
	
	[super dealloc];
}

@end

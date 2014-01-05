/**
 Introduced in: Part 7
 
 Requires you to add the CoreVideo framework to your project if you want to use this.
 */
#import "GLK2Texture.h"

@interface GLK2Texture (CoreVideo)

+(GLK2Texture*) texturePreCreatedByApplesCoreVideo:(CVOpenGLESTextureRef) applCoreVideoTexture;

@end

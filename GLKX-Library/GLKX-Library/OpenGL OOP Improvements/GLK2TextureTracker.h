/**
 Tracks all GL texture allocation, creation, destruction, re-use, etc.
 
 ALSO: intelligently manages memory for textures (e.g. calling glDeleteTextures
 when appropriate).
 
 Partly this class is for debugging! If only Apple's Frame-analyzer were faster / had the
 features of ATI, nVidia, etc.
 
 BUT ALSO: this class is very useful as a low-level / generic texture management system.
 You can extend it / build on it to make your own custom manager - but this handles the
 very basics that all GL apps need.
 */
#import <Foundation/Foundation.h>

#import "GLK2Texture.h"

@interface GLK2TextureTracker : NSObject

+(GLK2TextureTracker*) sharedInstance;

#pragma mark - General methods for supporting 3rd party classes

/** If you create a texture manually, NOT using GLK2Texture, make sure you inform the tracker, or else it MIGHT auto-delete your texture when there are no more GLK2Texture's using it */
-(void) gpuTextureCreatedWithoutClassTexture:(GLuint) textureName;
/** Signals to this class that it MAY delete the GPU texture if nothing else is still using it */
-(void) gpuTextureReleasedWithoutClassTexture:(GLuint) textureName;

#pragma mark - Automatic Integration with GLKX / GLK2 classes

/** Invoked by GLK2Texture every time a new class is created on CPU representing a texture */
-(void) classTextureCreated:(GLK2Texture*) texture;

/** Invoked by GLK2Texture every time a class on CPU representing a texture is dealloc'd */
-(void) classTextureDeallocing:(GLK2Texture*) texture;

#pragma mark - Useful diagnostics and output info

-(NSUInteger) totalGLTexturesCurrentlyOnGPU;

@end

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

typedef enum GLK2TextureTrackerCleanupMode
{
	GLK2TextureTrackerCleanupModeInstant = 0, // instantaneously cals glDeleteTextures whenever a texture has no referrers
	GLK2TextureTrackerCleanupModePeriodic // requires you to manually call garbageCollectDanglingGPUTextures periodically
} GLK2TextureTrackerCleanupMode;

@interface GLK2TextureTracker : NSObject

+(GLK2TextureTracker*) sharedInstance;

#pragma mark - Critical cleanup

@property(nonatomic) GLK2TextureTrackerCleanupMode cleanupMode;

/** 
 If you change cleanupMode to GLK2TextureTrackerCleanupModePeriodic, you MUST call this method periodically,
 or you will get infinite memory leaks every time you stop using a texture
 
 Alternatively, use the default mode and cleanup will be done automatically for each texture as soon as the
 texture is no longer in use.
 
 Call this periodically - e.g. once at end of each frame
 */
-(NSUInteger) garbageCollectDanglingGPUTextures;

#pragma mark - General methods for supporting 3rd party classes

/** If you create a texture manually, NOT using GLK2Texture, make sure you inform the tracker, or else it MIGHT auto-delete your texture when there are no more GLK2Texture's using it */
-(void) gpuTextureCreatedWithoutClassTexture:(GLuint) textureName;
/** Signals to this class that it MAY delete the GPU texture if nothing else is still using it */
-(void) gpuTextureReleasedWithoutClassTexture:(GLuint) textureName;

-(void) gpuTextureArtificiallyRetain:(GLuint)textureName retainer:(NSObject*) retainer;
-(void) gpuTextureStopArtificiallyRetaining:(GLuint)textureName retainer:(NSObject*) retainer;

#pragma mark - Automatic Integration with GLKX / GLK2 classes

/** Invoked by GLK2Texture every time a new class is created on CPU representing a texture */
-(void) classTextureCreated:(GLK2Texture*) texture;

/** Invoked when GLK2Texture disassociates from one GPU texture, and reassociates with another */
-(void)classTexture:(GLK2Texture*) texture switchingFrom:(GLuint)oldTextureName toNew:(GLuint)newTextureName;

/** Invoked by GLK2Texture every time a class on CPU representing a texture is dealloc'd */
-(void) classTextureDeallocing:(GLK2Texture*) texture;

#pragma mark - Useful diagnostics and output info

-(NSUInteger) totalGLTexturesCurrentlyOnGPU;
-(NSArray*) textureNamesOnGPU;
-(NSArray*) referencesToTexture:(GLuint) textureName;

@end

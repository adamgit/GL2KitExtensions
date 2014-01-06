/**
 Introduced in: Part 7
 
 Based on Apple's example source code "PVRTexture.h / .m version 1.5", heavily modified
 
 Apple's code is very outdated, and only loads v1 PVR files. PVR supports these using
 the "legacy" option in the Imagination / PVR tools - anything else will fail / crash.
 */

#import <UIKit/UIKit.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "GLK2Texture.h"

@interface PVRTextureV1 : GLK2Texture

@property(nonatomic,retain,readonly) NSMutableArray *imageData;

@property(nonatomic,readonly) uint32_t width, height;

@property(nonatomic,readonly) GLenum internalFormat;
@property(nonatomic,readonly) BOOL hasAlpha;

/** filename/path if it was from disk, or URL string if from URL */
@property(nonatomic,retain,readonly) NSString* textureSourceFileInfo;

@end

@interface GLK2TextureLoaderPVRv1 : NSObject

/**
 Returns a GL2KTexture object, with the PVR texture pre-uploaded to the GPU,
 and any MipMaps created as appropriate, as limited by setMaximumTextureSizeToLoadInMipMaps:
 */
+ (PVRTextureV1*)pvrTextureWithContentsOfFile:(NSString *)path;

/**
 Returns a GL2KTexture object, with the PVR texture pre-uploaded to the GPU,
 and any MipMaps created as appropriate, as limited by setMaximumTextureSizeToLoadInMipMaps:
 */
+ (PVRTextureV1*)pvrTextureWithContentsOfURL:(NSURL *)url;

/**
 Some Apple hardware - most notably the iPad Mini - "can" read 4k,4k textures, but the thing has
 nowhere near enough RAM to actually run an app at the same time (it uses same-size textures as an
 iPad 3 / 4 / 5, but has ONE QUARTER of the RAM!).
 
 This method allows you to prevent mipmaps being loaded, even if the chip says it "can", but you know
 it "shouldn't"
 
 This is measured in the same units as GL's glGetIntegerv( GL_MAX_TEXTURE_SIZE, ... ) - e.g. 4096 is
 equal to "a texture 4096 pixels wide, and 4096 pixels high"
 
 If you send a value of "0" that will be treated as "no limit" (which is the default)
 */
+(void)setMaximumTextureSizeToLoadInMipMaps:(GLint) newMax;

@end
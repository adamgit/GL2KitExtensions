/**
 Lots of bits of OpenGL *require* you to manage a global status of all textures;
 unfortunately, OpenGL is too dumb to do things like track "you're about to run
 out of texture memory" -- it doesn't even allow you to ask how much texture memory is in use / available.
 
 This is perhaps not as bad as it sounds: memory fragmentation is a real problem, and
 being forced to build your own texture manager forces you to write code that copes well
 with fragmentation failures (i.e. "you have enough VRAM, but it's not contiguous, so
 the GPU can't allocate it all at once, although it *can* allocate it in small pieces").
 
 Net effect: every developer has to write a singleton class to centralise all texture
 allocation, and ensure that you never run out and/or that you react intelligently when
 you do run out (which is inevitable!)
 */
#import <Foundation/Foundation.h>
#import "GLK2Texture.h"

@interface GLK2TextureManager : NSObject

/** The versions that use a GLK2Texture are preferred - but these versions work with any GL texture,
 no matter which library created it */
+(void) didCreateTextureWithName:(GLuint) textureName;
/** The versions that use a GLK2Texture are preferred - but these versions work with any GL texture,
 no matter which library created it */
+(void) willDestroyTextureWithName:(GLuint) textureName;

/**
 For this class to work, you MUST ensure all GLK2Texture subclasses invoke this whenever they alloc/init
 */
+(void) didCreateTexture:(GLK2Texture*) texture;
/**
 For this class to work, you MUST ensure all GLK2Texture subclasses invoke this whenever they dealloc
 */
+(void) willDestroyTexture:(GLK2Texture*) texture;


/**
 Only returns the GLK2Texture objects we know about
 
 This returns GLK2Texture's
 
 Method signature is the superset of NSSet, NSArray - so I can change the internal storage later if desired */
+(NSObject <NSCopying, NSSecureCoding, NSFastEnumeration> *)allKnownGLK2Textures;

/**
 Returns ALL OpenGL names for textures - every GLK2Texture will have one, but some
 non-GLK2Textures (created by 3rd party API's) will be here too.
 
 This returns an enumeratable thing of NSNumber's
 
 Method signature is the superset of NSSet, NSArray - so I can change the internal storage later if desired */
+(NSObject <NSCopying, NSSecureCoding, NSFastEnumeration> *)allKnownTextureNames;

+(NSString*) debugInstanceDescription;

@end

/**
 From the OpenGL org wiki (http://www.opengl.org/wiki/Texture):
 
    "Binding textures for use in OpenGL is a little weird."
 
 -- Really? You don't say...
 
 And Apple solves half the problems, but creates as many new problems as the ones they solve.
 
 ARGH!
 
 So ... this is an annoying class, it shouldn't be needed - but it is, let me explain...
 
 -------------- (explanation starts) --------------
 From the Apple docs on GLKTextureInfo:
 
 (https://developer.apple.com/library/ios/documentation/GLkit/Reference/GLKTextureInfo_Ref/Reference/Reference.html#//apple_ref/occ/instp/GLKTextureInfo/textureOrigin)
 
 "Your app never creates GLKTextureInfo objects directly"
 
 Why? Ideology? Someone at Apple doesn't like other programmers writing
 source code, adding features, fixing bugs, extending functionality?
 
 If Apple's GLKTextureLoader class actually worked (it doesn't; it has massive bugs - that
 I've reported to Apple, but been told 'I'll never fix it' by Apple engineers)
 ... maybe they could get away with sealing their classes like this.
 
 But it doesn't work. And it doesn't support PVR any more (the file-format has moved on,
 Apple's source code is now obsolete, and Apple hasn't updated it). So ... we need to
 replace GLKTextureInfo with a class that we're "allowed" to set values on, so we can
 fix Apple's bugs.
 -------------- (explanation ends) --------------
 
 What does this class does:
 
 - unifies "Apple's proprietary GLKTextureInfo class" with "genuine OpenGL textures"
 - represents 1:1 an OpenGL texture
 - OpenGL textures can live on CPU, GPU, both, neither - this class tracks where the texture is, and if it needs reloading
 - provides a single datatype that your own, custom, texture importers can safely import to, and your app code can read from
 
 Very important:
 
 - this class can UNLOAD it's texture from the GPU (e.g. when low on memory), and then RELOAD it later, while the app is running
 
 (OpenGL can't/won't do that automatically, and if you don't track texture-status using a class like this one, it's hard
 to do yourself)
 
 */
#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface GLK2Texture : NSObject

+(GLK2Texture*) texturePreLoadedByApplesGLKit:(GLKTextureInfo*) appleMetadata;

/** OpenGL uses integers as "names" instead of Strings, because Strings in C are a pain to work with, and slower */
@property(nonatomic, readonly) GLuint glName;

/** Creates a new, blank, OpenGL texture on the GPU.
 
 If you already created a texture from some other source, use the initWithName: method instead
 */
- (id)init;

/** If a texture was loaded by an external source - e.g. Apple's GLKit - you'll already have a name for it, and can
 use this method
 */
- (id)initWithName:(GLuint) name;

@end

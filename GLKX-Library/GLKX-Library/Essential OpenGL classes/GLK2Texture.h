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

#define USE_GLK2TEXTURETRACKER_INTERNALLY 1 // set to 0 if you want to build without the extended classes e.g. GLK2TextureTracker

@interface GLK2Texture : NSObject

/**
 Creates a new empty texture on the GPU. You'll have to fill this later with one of the uploading methods.
 
 Generally, you do NOT want this method - it's best to upload a texture immmediately, or not create it until you
 need it. But in some cases (e.g. when multiple drawcalls are going to share a texture) it's safer to create the
 GPU texture first, and pass this texture object to each drawcall during config, so that they never get out of
 synch, and upload the texture data later.
 */
+(GLK2Texture*) textureNewEmpty;

/** Tries to load a texture in the same way as Apple's [UIImage imageNamed] method: by searching the bundle, and then
 delegating to Apple's broken GLKit texture-loader (because that loader explicitly is designed to do this, even though
 it's very buggy) */
+(GLK2Texture*) textureNamed:(NSString*) filename;

/** If you use Apple's broken GLKit texture-loader, you'll need to store and manipulate the output, but Apple blocks you
 from doing this (for no apparent reason). So this method lets you convert from Apple's badly designed proprietary class
 into an instance that you can safely use */
+(GLK2Texture*) texturePreLoadedByApplesGLKit:(GLKTextureInfo*) appleMetadata;

/**
 If your texture is already on the GPU and/or was created by 3rdparty code, this lets you
 create a CPU-side GLK2Texture object to manage it
 */
+(GLK2Texture*) textureAlreadyOnGPUWithName:(GLuint) existingName;

/**
 Note that a raw stream of bytes contains NO INFORMATION about width/height of texture, so you need to provide those
 details in the parametrs.
 
 Critically important: this requires the data to be in RAW BYTES, exactly as you'd expect from the method name; this is
 INCOMPATIBLE with Apple's undocumented NSData-loading method (which crashes if you give it anything except
 an ENCODED jpeg or png or pvr-v1) */
+(GLK2Texture *)textureFromNSData:(NSData *)rawData pixelsWide:(int) pWide pixelsHigh:(int) pHigh;

/** OpenGL uses integers as "names" instead of Strings, because Strings in C are a pain to work with, and slower */
@property(nonatomic, readonly) GLuint glName;

/**
 DEFAULTS to FALSE
 
 There is one known case where you DON'T want to delete your own textures:
 Apple's badly-documented CoreVideo for pulling frames from Camera onto GL texture, where Apple REQUIRES you to manually buffer
 textures from frame-to-frame until they "die" at a non-specified time of Apple's internal choosing */
@property(nonatomic) BOOL disableAutoDelete;

/** Creates a new, blank, OpenGL texture on the GPU.
 
 If you already created a texture from some other source, use the initWithName: method instead
 */
- (id)init;

/** If a texture was loaded by an external source - e.g. Apple's GLKit - you'll already have a name for it, and can
 use this method
 
 NB: this is the designated initializer; this is particularly important w.r.t. GLK2TextureTracker and subclassing
 this class
 */
- (id)initWithName:(GLuint) name;

-(void) uploadFromNSData:(NSData *)rawData pixelsWide:(int) pWide pixelsHigh:(int) pHigh;

/** Advanced:
 
 Mostly useful when hot-swapping a teture, this call drops the old .glName (and issues a glDeleteTeture on it
 unless willDeleteOnDealloc is set to FALSE), then it grabs the incoming value and sets it as self.glName.
 
 From this moment onwards, all rendering that indirects via this instance will use the "new" GPU-side teture
 instead of the old one.
 */
-(void) reAssociateWithNewGPUTexture:(GLuint) newTextureName;

/** Wraps the texture in S */
-(void) setWrapSRepeat;
-(void) setWrapTRepeat;
/** Clamps the texture in S */
-(void) setWrapSClamp;
-(void) setWrapTClamp;

@end

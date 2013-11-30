/**
 Requesting this info actually takes time, but cannot change over lifetime of the app,
 because it's permanent hardware info.
 
 Note: some Android phones might switch between multiple GPUs, but for OpenGL ES on iOS
 ... you'll only ever have one GPU / GL driver available
 
 Makes life easier to collect this info at program start, and cache it on CPU side.
 
 Make sure you call [* readAllGLMaximums] at least once at the start of your app - but AFTER
 the GL has been setup and configured, and you've done a [GLKview bindDrawable] etc
 */
#import <Foundation/Foundation.h>

/** Apple's engineers are misguided in believing you can write software without knowing how
 much RAM is in the physical device.
 
 With OpenGL, where e.g. iPad Mini loads the same 4k
 textures as an iPad3, but has considerably LESS RAM ... you WILL get crashes if you try to
 load the same textures on both devices.
 */
typedef NS_ENUM(NSInteger, DeviceMemoryInBytes )
{
	DeviceMemory0Bytes,
	DeviceMemory128MegaBytes,
	DeviceMemory256MegaBytes,
	DeviceMemory512MegaBytes,
	DeviceMemory1024MegaBytes,
	DeviceMemory2048MegaBytes
};

@interface GLK2HardwareMaximums : NSObject

/**
 Invoke this method to read + cache all GL hardware data. You need to do this at least once!
 */
-(void) readAllGLMaximums;

@property(nonatomic,readonly) GLint glMaxTextureSize;
@property(nonatomic,readonly) DeviceMemoryInBytes iOSDeviceRAM;

@end

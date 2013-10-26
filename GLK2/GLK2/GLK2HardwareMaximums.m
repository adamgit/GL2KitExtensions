#import "GLK2HardwareMaximums.h"

#include <sys/types.h> // So we can calculate RAM in device
#include <sys/sysctl.h> // So we can calculate RAM in device

@interface GLK2HardwareMaximums()
@property(nonatomic,readwrite) GLint glMaxTextureSize;
@property(nonatomic,readwrite) DeviceMemoryInBytes iOSDeviceRAM;
@end

@implementation GLK2HardwareMaximums

-(void) readAllGLMaximums
{
	glGetIntegerv( GL_MAX_TEXTURE_SIZE, &_glMaxTextureSize );

	/**
	 This section exists because Apple refuses to give core info to iOS developers.
	 
	 It is not possible to make games that work on 128Mb ram and 1,024Mb
	 RAM while ignoring the difference. It's stupid to pretend otherwise!
	 
	 Data comes from Wikipedia etc on which hardware-codes refer to which device, with how much RAM
	 */
	size_t size;
	sysctlbyname("hw.machine", NULL, &size, NULL, 0);
	char *machine = malloc(size);
	sysctlbyname("hw.machine", machine, &size, NULL, 0);
	NSString *platform = [NSString stringWithUTF8String:machine];
	free(machine);
	
	if( [platform hasPrefix:@"iPhone1"])
		self.iOSDeviceRAM = DeviceMemory128MegaBytes;
	else if( [platform hasPrefix:@"iPhone2"])
		self.iOSDeviceRAM =  DeviceMemory256MegaBytes;
	else if( [platform hasPrefix:@"iPhone3"]) // iPhone4 in reality
		self.iOSDeviceRAM =  DeviceMemory512MegaBytes;
	else if( [platform hasPrefix:@"iPhone4"]) // iPhone4S in reality
		self.iOSDeviceRAM =  DeviceMemory1024MegaBytes;
	else if( [platform hasPrefix:@"iPhone5"]) // iPhone5 AND iPhone5C
		self.iOSDeviceRAM =  DeviceMemory1024MegaBytes;
	else if( [platform hasPrefix:@"iPhone6"]) // iPhone5S in reality
		self.iOSDeviceRAM =  DeviceMemory1024MegaBytes;
	else if( [platform hasPrefix:@"iPhone"]) // catch-all for higher-end devices not yet existing
		self.iOSDeviceRAM =  DeviceMemory1024MegaBytes;
	
	else if( [platform hasPrefix:@"iPod1"])
		self.iOSDeviceRAM = DeviceMemory128MegaBytes;
	else if( [platform hasPrefix:@"iPod2"])
		self.iOSDeviceRAM =  DeviceMemory128MegaBytes;
	else if( [platform hasPrefix:@"iPod3"])
		self.iOSDeviceRAM =  DeviceMemory256MegaBytes;
	else if( [platform hasPrefix:@"iPod4"])
		self.iOSDeviceRAM =  DeviceMemory256MegaBytes;
	else if( [platform hasPrefix:@"iPod5"])
		self.iOSDeviceRAM =  DeviceMemory512MegaBytes;
	else if( [platform hasPrefix:@"iPod"]) // catch-all for higher-end devices not yet existing
		self.iOSDeviceRAM =  DeviceMemory512MegaBytes;

	else if( [platform hasPrefix:@"iPad1"])
		self.iOSDeviceRAM = DeviceMemory256MegaBytes;
	else if( [platform hasPrefix:@"iPad2"]) // includes iPad Mini, which has same RAM as iPad2
		self.iOSDeviceRAM =  DeviceMemory512MegaBytes;
	else if( [platform hasPrefix:@"iPad3"])
		self.iOSDeviceRAM =  DeviceMemory2048MegaBytes;
	else if( [platform hasPrefix:@"iPad4"])
		self.iOSDeviceRAM =  DeviceMemory2048MegaBytes;
	else if( [platform hasPrefix:@"iPad5"])
		self.iOSDeviceRAM =  DeviceMemory2048MegaBytes;
	else if( [platform hasPrefix:@"iPad"]) // catch-all for higher-end devices not yet existing
		self.iOSDeviceRAM =  DeviceMemory2048MegaBytes;
	
	else if( [platform hasPrefix:@"x86_64"])
		self.iOSDeviceRAM = DeviceMemory1024MegaBytes; // Simulator, running on desktop machine
}

@end

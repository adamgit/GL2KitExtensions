#import "MemoryUsageViewController.h"

#import <mach/mach.h>
#import <mach/mach_host.h>

#import "GLK2Texture.h"
#import <GLKit/GLKit.h>

#import "GLK2TextureLoaderPVRv1.h"

#pragma mark - Class Extension (private properties etc)
@interface MemoryUsageViewController ()
@property(nonatomic,retain) NSTimer* timerForUpdatingMemUsage;
@property(nonatomic,retain) EAGLContext* myContext;
@property(nonatomic,retain) GLK2Texture* texture1, * texture2;
@end

#pragma mark - Main Class
@implementation MemoryUsageViewController

/** Apple Storyboards ONLY call this method */
-(id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
    if (self) {
		self.myContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
		[EAGLContext setCurrentContext:self.myContext];
		
		self.timerForUpdatingMemUsage = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(tickCheckMemUsage) userInfo:nil repeats:TRUE];
    }
    return self;
}

/** In source code, you can ONLY call this method */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) tickCheckMemUsage
{
	mach_port_t hostPort;
	mach_msg_type_number_t hostSize;
	vm_size_t pageSize;
	
	hostPort = mach_host_self();
	hostSize = sizeof( vm_statistics_data_t) / sizeof(integer_t);
	host_page_size( hostPort, &pageSize);
	
	vm_statistics_data_t vmStat;
	
	if( host_statistics( hostPort, HOST_VM_INFO, (host_info_t) &vmStat, &hostSize) != KERN_SUCCESS)
	{
		NSLog(@"failed");
	}
	else
	{
		natural_t memUsed = (vmStat.active_count + vmStat.inactive_count + vmStat.wire_count) * pageSize;
		
		natural_t memFree = vmStat.free_count * pageSize;
	//	natural_t memTotal = memUsed + memFree;
		
		self.lFreeMem.text = [NSString stringWithFormat:@"%@ bytes", [NSNumberFormatter localizedStringFromNumber:@(memFree) numberStyle:NSNumberFormatterDecimalStyle]];
		self.lUsedMem.text = [NSString stringWithFormat:@"%@ bytes", [NSNumberFormatter localizedStringFromNumber:@(memUsed) numberStyle:NSNumberFormatterDecimalStyle]];
	}
}

-(void)tappedLoadTexture1:(id)sender
{
	self.texture1 = [GLK2Texture textureNamed:@"world.topo.bathy.200412.3x16384x8192.A1-legacy"];
}

-(void)tappedUnloadTexture1:(id)sender
{
	self.texture1 = nil;
}

-(void)tappedLoadTexture2:(id)sender
{
	self.texture2 = [GLK2Texture textureNamed:@"world.topo.200412.3x5400x2700"];
}

-(void)tappedUnloadTexture2:(id)sender
{
	self.texture2 = nil;
}

@end

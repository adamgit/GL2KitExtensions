#import <XCTest/XCTest.h>

#import "GLK2TextureTracker.h"
#import "GLK2TextureTracker_UnitTesting.h"

@interface GLKX_Test_OOP_Improvements : XCTestCase
@property(nonatomic,retain) EAGLContext* privateGLContext;
@end

@implementation GLKX_Test_OOP_Improvements

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
	
	self.privateGLContext = [[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2] autorelease];
	[EAGLContext setCurrentContext:self.privateGLContext];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
	
	/** Critically important to ensure that each test is isolated from the behaviour of the others: */
	[GLK2TextureTracker forceDeallocSharedInstance];
	
	/** Critically important to ensure that each test is isolated from the behaviour of the others: */
	// ... must come last! This kills the GL context (potentially)
	[EAGLContext setCurrentContext:nil];
	self.privateGLContext = nil;
}

- (void)testTextureTrackerAddsTextures
{
	GLK2TextureTracker* tracker = [GLK2TextureTracker sharedInstance];
	XCTAssertEqual( tracker.totalGLTexturesCurrentlyOnGPU, 0, @"Should be no textures yet");
	
	
	GLK2Texture* newClassTexture = [GLK2Texture textureNewEmpty];
	XCTAssertNotEqual( 0, newClassTexture.glName, @"Texture created OK on GPU (proves we have a valid EAGLContext)");
	XCTAssertEqual( tracker.totalGLTexturesCurrentlyOnGPU, 1, @"Should now be 1 tracked texture");	
}

- (void)testTextureTrackerDropsTextures
{
	GLK2TextureTracker* tracker = [GLK2TextureTracker sharedInstance];
	XCTAssertEqual( tracker.totalGLTexturesCurrentlyOnGPU, 0, @"Should be no textures yet");
	
	GLK2Texture* temporaryClassTexture;
	@autoreleasepool
	{
		temporaryClassTexture = [GLK2Texture textureNewEmpty];
		XCTAssertEqual( tracker.totalGLTexturesCurrentlyOnGPU, 1, @"Should now be 1 tracked texture");
	}
	XCTAssertEqual( tracker.totalGLTexturesCurrentlyOnGPU, 0, @"The temporary texture should have been dropped, and the GL texture untracked");
}


@end

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

#import "GLK2HardwareMaximums.h"

@interface ViewController : GLKViewController

/**
 An EAGLContext is needed for 95% of OpenGL calls to work.
 
 It's supposed to be 100%, but some - e.g. glClear - miraculously work without it
 */
@property(nonatomic,retain) EAGLContext* localContext;

/** Info about GL that you need to read-back frequently in your app */
@property(nonatomic,retain) GLK2HardwareMaximums* hardwareMaximums;

/**
 Every app needs to use its own code here: the exact set of draw-calls
 is where the custom rendering takes place, or is configured
 */
-(NSMutableArray*) createAllDrawCalls;

@end

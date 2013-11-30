#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface ViewController : GLKViewController

/**
 An EAGLContext is needed for 95% of OpenGL calls to work.
 
 It's supposed to be 100%, but some - e.g. glClear - miraculously work without it
 */
@property(nonatomic,retain) EAGLContext* localContext;

/**
 Every app needs to use its own code here: the exact set of draw-calls
 is where the custom rendering takes place, or is configured
 */
-(NSMutableArray*) createAllDrawCalls;

@end

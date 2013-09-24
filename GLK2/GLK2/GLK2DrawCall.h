#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

/**
 Version 1: c.f. http://t-machine.org/index.php/2013/09/08/opengl-es-2-basic-drawing/
 */
@interface GLK2DrawCall : NSObject

@property(nonatomic) BOOL shouldClearColorBit;

/**
 Defaults to:
 
 - clear color MAGENTA
 
 ... everything else: OFF
 */
- (id)init;

-(float*) clearColourArray;
-(void) setClearColourRed:(float) r green:(float) g blue:(float) b alpha:(float) a;

@end

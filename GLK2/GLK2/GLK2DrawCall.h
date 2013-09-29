#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "GLK2ShaderProgram.h"

/**
 Version 1: c.f. http://t-machine.org/index.php/2013/09/08/opengl-es-2-basic-drawing/
 Part 3: ... not published yet ...
 */
@interface GLK2DrawCall : NSObject

@property(nonatomic) BOOL shouldClearColorBit;

/** Every draw call MUST have a shaderprogram, or else it cannot draw objects nor pixels */
@property(nonatomic,retain) GLK2ShaderProgram* shaderProgram;

/**
 Defaults to:
 
 - clear color MAGENTA
 
 ... everything else: OFF
 */
- (id)init;

-(float*) clearColourArray;
-(void) setClearColourRed:(float) r green:(float) g blue:(float) b alpha:(float) a;

@end

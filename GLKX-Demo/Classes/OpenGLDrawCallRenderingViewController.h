/**
 
 The simplest possible generic extension of Apple's GLKViewController
 
 The main thing this adds is support for "GLK2DrawCall" - the essential class that any OpenGL app
 will need (or need to re-invent)
 
 */
#import <UIKit/UIKit.h>

#import <GLKit/GLKit.h>

#import "GLK2DrawCall.h"
#import "GLK2HardwareMaximums.h"

@interface OpenGLDrawCallRenderingViewController : GLKViewController

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

/** Called prior to rendeirng a draw-call, enabling subclasses to e.g. change uniforms
 just prior to that draw-call being rendered
 
 NB: this is called AFTER the VAO and shader-program have been set - so you are safe
 to immediately, nakedly, set Uniforms etc
 */
-(void) willRenderDrawCallUsingVAOShaderProgramAndDefaultUniforms:(GLK2DrawCall*) drawCall;

@end

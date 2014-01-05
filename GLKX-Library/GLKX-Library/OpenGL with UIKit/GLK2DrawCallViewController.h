/**
 Extension of Apple's GLKViewController that adds support for the
 GLK2DrawCall class. OpenGL revolves around Draw calls!
 
 This class implements the basic OpenGL rendering loop, layered on
 top of Apple's GLKViewController built-in loop:
 
 0. GENERAL: integrates correctly with viewDidLoad etc, as per Apple docs
 1. SETUP: create and set a valid EAGLContext, or crash/error
 2. SETUP: generate a set of "initial Draw calls" (or none)
 3. LOOP FOREVER: render a single "frame" to the screen
 
 The "frame" doesn't exist in OpenGL, strictly speaking, but it's a
 useful concept. To render a frame, we split it up like this:
 
 3a. EACH FRAME: callback for subclasses to know a new frame is starting
 3b. EACH FRAME: request a sorted list of Draw calls to render
 3c. EACH FRAME LOOP: for each Draw call:
   3c-i. update all GL state
   3c-ii. update all shader-uniforms
   3c-iii. render that Draw call
   3c-iv. reset state as required
 
 OpenGL ES 2 has approximately 15 different pieces of "high-level"
 render-state; to render a single Draw call, all of them have to be
 turned on, or off, and configured, or reset, or re-allocated, or
 re-uploaded (e.g. texture maps). Hence the "for each Draw call"
 above is a lot of boilerplate code.
 
 IMPORTANT NOTE:
 
 This class is incomplete; it only handles the bits of GL state that have
 been covered by the tutorials already posted to http://t-machine.org - anything
 not yet written about will need to be added by hand if you use this class.
 */
#import <UIKit/UIKit.h>

#import <GLKit/GLKit.h>

#import "GLK2DrawCall.h"
#import "GLK2HardwareMaximums.h"

@interface GLK2DrawCallViewController : GLKViewController

/**
 An EAGLContext is needed for 95% of OpenGL calls to work.
 
 It's supposed to be 100%, but some - e.g. glClear - miraculously work without it
 when running on Apple OS's.
 */
@property(nonatomic,retain) EAGLContext* localContext;

@property(nonatomic, retain) NSMutableArray* drawCalls;

/** Info about GL that you need to read-back frequently in your app */
@property(nonatomic,retain) GLK2HardwareMaximums* hardwareMaximums;

/**
 Every app needs to use its own code here: the exact set of draw-calls
 is where the custom rendering takes place, or is configured
 */
-(NSMutableArray*) createAllDrawCalls;

/**
 Called once at start of each frame; sole purpose is to allow you to do per-frame
 setup (note: per-drawcall setup of Uniforms is done in a different callback)
 */
-(void)willRenderFrame;

/** Called prior to rendering a draw-call, enabling subclasses to e.g. change uniforms
 just prior to that draw-call being rendered
 
 NB: this is called AFTER the VAO and shader-program have been set - so you are safe
 to immediately, nakedly, set Uniforms etc
 */
-(void) willRenderDrawCallUsingVAOShaderProgramAndDefaultUniforms:(GLK2DrawCall*) drawCall;

@end

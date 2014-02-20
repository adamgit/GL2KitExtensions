/**
 Part 3: ... not published yet ...
 
 ShaderProgram is a boilerplate concept that is REQUIRED to be identical for all OpenGL apps; this class is intended to be
 reused everywhere without changes. A ShaderProgram in OpenGL ES 2 is "1 x vertex shader + 1 x fragment shader, combined into
 a single item".
 
 (NB: this version is incomplete, a basic implementation only, next version will add a few missing features, and then never
 need to be edited again)
 */
#import <Foundation/Foundation.h>

#import "GLK2Attribute.h"
#import "GLK2Uniform.h"

#define DEBUG_ATTRIBUTE_HANDLING 0
#define DEBUG_UNIFORM_HANDLING 0

typedef enum GLK2ShaderProgramStatus
{
	GLK2ShaderProgramStatusUnlinked,
	GLK2ShaderProgramStatusLinked
} GLK2ShaderProgramStatus;

@class GLK2Shader;

@interface GLK2ShaderProgram : NSObject

/**
 
 Does all the work of:
 
 - finding vertex + fragment shaders on disk
 - loading the source code of the shaders
 - compiling them
 - linking them
 - storing post-link info that OpenGL apps MUST have in order to work corectly
 
 */
+(GLK2ShaderProgram*) shaderProgramFromVertexFilename:(NSString*) vFilename fragmentFilename:(NSString*) fFilename;

@property(nonatomic) GLK2ShaderProgramStatus status;

/** OpenGL uses integers as "names" instead of Strings, because Strings in C are a pain to work with, and slower */
@property(nonatomic, readonly) GLuint glName;

/** Setting either property automatically calls glAttachShader */
@property(nonatomic,retain) GLK2Shader* vertexShader, * fragmentShader;

/** the "link" stage automatically finds all "attribute" lines in the shader source, and creates one GLK2Attribute for each */
-(GLK2Attribute*) attributeNamed:(NSString*) name;
/** the "link" stage automatically finds all "attribute" lines in the shader source, and creates one GLK2Attribute for each */
-(NSArray*) allAttributes;

-(GLK2Uniform*) uniformNamed:(NSString*) name;
-(NSArray*) allUniforms;

#pragma mark - GLSL validation - do NOT use in a live app!

-(void) validate;

#pragma mark - Set the value of a Uniform

/**
 NOTE: it is always safe to call this from anywhere in the program, so long as the renderer's thread is blocked,
 OR you are inside that thread.
 
 The simpler/faster version of this method only works if you are actually inside the render-loop itself, which is
 only true for the renderer
 
 Note: both methods set internal state that helps with debugging; you can use either - but don't use the private
 internal methods!
 */
-(void) setValueOutsideRenderLoopRestoringProgramAfterwards:(const void*) value forUniform:(GLK2Uniform*) uniform;

/** NOTE: this must ONLY be invoked inside the main render-loop, and ONLY when the render-loop has set the
 current glProgram to this one.
 
 When you need to set values outside the render-loop - e.g. nearly always: because you're configuring a new shader/
 drawcall - instead use setValueOutsideRenderLoopRestoringProgramAfterwards:forUniform -- that method will switch to
 this shaderprogram, set the value, and then switch BACK to the original program being used by the main renderer.
 
 If you incorrectly use this method when you should have used the other, GL state will leak between drawcalls/shaders
 and CHAOS! will break loose upon thy rendering... You will also think you've gone insane when you try to debug it,
 and 1 proves to be equal to 0. (voice of bitter experience)
 
 Note: both methods set internal state that helps with debugging; you can use either - but don't use the private
 internal methods!
 */
-(void) setValue:(const void*) value forUniform:(GLK2Uniform*) uniform;

/**
 OpenGL debugging is badly designed and almost unusable; all manufacturers provide hacks to give you what you need,
 except Apple - who prevents you from using the manufacturer's tools (Imagination / PowerVR doesn't seem very happy
 about this!).
 
 One side-effect: OpenGL will silently break everything if a Uniform that needs to be set ... isn't ... for any reason
 and will not give you any way of finding this out.
 
 This method tracks (imperfectly, but accurate so long as you only use the public methods in this class) what uniforms
 you've set / not set yet
 */
-(NSArray*) uniformsWithoutValues;

/** automatically calls glCreateProgram() */
- (id)init;

@end

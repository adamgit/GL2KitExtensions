/**
 In OpenGL, unlike other 3D systems, you CAN NEVER HAVE "just" a Shader ... you MUST ALWAYS HAVE a "Shader Program", which is
 defined as "the combination of a Vertex Shader with a Fragment Shader".
 
 Further, in OpenGL ES, a "Shader Program" MUST HAVE exactly 1 Vertex Shader and exactly 1 Fragment Shader (desktop OpenGL can
 have multiple - but ES simplifies things here)
 
 This class mostly serves to take "two text files - one for vertexShader, one for fragmentShader - and do all the extensive work
 necessary to get them onto the GPU as a "ready-to-use" ShaderProgram". There is a lot more involved than you might innocently
 imagine - allegedly for historic reasons going back to the 1990's and 3DLabs (!).
 
 95% of this work is IDENTICAL FOR ALL APPS. So ... Use the static method, it does lots of work for you, and ensures everything is configured properly. It's the one-liner that we expected
 Apple to provide in GLKit, but which they didn't.
 */
#import <Foundation/Foundation.h>

#import "GLK2Uniform.h"
#import "GLK2Attribute.h"

typedef enum GLK2ShaderProgramStatus
{
	GLK2ShaderProgramStatusUnlinked,
	GLK2ShaderProgramStatusLinked
} GLK2ShaderProgramStatus;

@class GLK2Shader;

@interface GLK2ShaderProgram : NSObject

/**
 Does all the work of:
 
 creating vertex + fragment shaders
 loading the shaders from filenames
 compiling them
 binding attributes
 linking them
 storing uniform-locations
 hooking up the shaders into the resulting program
 */
+(GLK2ShaderProgram*) shaderProgramFromVertexFilename:(NSString*) vFilename fragmentFilename:(NSString*) fFilename;

@property(nonatomic) GLK2ShaderProgramStatus status;
@property(nonatomic) GLuint glName;

/** Collectively, these three methods are "set the value of any Uniform in a Shader",
 but OpenGL requires us to invoke different API calls depending on the type, which is
 a pain in the ...
 */
-(void) setBooleanBasedValue:(GLboolean*) valuePointer forUniform:(GLK2Uniform*) uniform;

/** Collectively, these three methods are "set the value of any Uniform in a Shader",
 but OpenGL requires us to invoke different API calls depending on the type, which is
 a pain in the ...
 */
-(void) setIntBasedValue:(GLint*) valuePointer forUniform:(GLK2Uniform*) uniform;

/** Collectively, these three methods are "set the value of any Uniform in a Shader",
 but OpenGL requires us to invoke different API calls depending on the type, which is
 a pain in the ...
 */
-(void) setFloatBasedValue:(GLfloat*) valuePointer forUniform:(GLK2Uniform*) uniform transposeMatrix:(BOOL) shouldTranspose;


/** setting either property automatically calls glAttachShader */
@property(nonatomic,retain) GLK2Shader* vertexShader, * fragmentShader;

-(GLK2Uniform*) uniformNamed:(NSString*) name;
-(GLK2Attribute*) attributeNamed:(NSString*) name;
-(NSArray*) allUniforms;
-(NSArray*) allAttributes;
-(void) setValue:(const GLfloat*) value forUniform:(GLK2Uniform*) uniform;


/** automatically calls glCreateProgram() */
- (id)init;

@end

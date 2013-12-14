/**
 Each drawcall,  you can ask this object to provide values for any/all of the GL Uniforms
 in the current shader program.
 
 This attempts to efficiently extend VertexArrayObjects to cover ShaderProgram Uniforms,
 which the OpenGL committee failed to include.
 
 c.f. http://www.khronos.org/registry/gles/extensions/OES/OES_vertex_array_object.txt
 
 "This extension introduces vertex array objects which encapsulate
 vertex array states on the server side (vertex buffer objects).
 These objects aim to keep pointers to vertex data and to provide
 names for different sets of vertex data. Therefore applications are
 allowed to rapidly switch between different sets of vertex array
 state, and to easily return to the default vertex array state."
 
 Design:
  - whenever the engine switches to a new Draw call, it queries
 the Draw call for one of these objects
  - the engine inspects the current ShaderProgram to find out what
 Uniforms it possesses, and then asks this object to provide them
  - any value that this object DOES NOT PROVIDE (returns NULL or FALSE)
 causes the engine to NOT CHANGE THE EXISTING GPU-SIDE VALUE
 */
#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "GLK2Uniform.h"

@class GLK2DrawCall;

@protocol GLK2UniformValueGenerator <NSObject>

@optional

/** Returns NULL pointer if this object has no value / wants you to leave the value alone */
-(GLKVector2*) vector2ForUniform:(GLK2Uniform*) v inDrawCall:(GLK2DrawCall*) drawCall;
/** Returns NULL pointer if this object has no value / wants you to leave the value alone */
-(GLKVector3*) vector3ForUniform:(GLK2Uniform*) v inDrawCall:(GLK2DrawCall*) drawCall;
/** Returns NULL pointer if this object has no value / wants you to leave the value alone */
-(GLKVector4*) vector4ForUniform:(GLK2Uniform*) v inDrawCall:(GLK2DrawCall*) drawCall;

/** Returns NULL pointer if this object has no value / wants you to leave the value alone */
-(GLKMatrix2*) matrix2ForUniform:(GLK2Uniform*) v inDrawCall:(GLK2DrawCall*) drawCall;
/** Returns NULL pointer if this object has no value / wants you to leave the value alone */
-(GLKMatrix3*) matrix3ForUniform:(GLK2Uniform*) v inDrawCall:(GLK2DrawCall*) drawCall;
/** Returns NULL pointer if this object has no value / wants you to leave the value alone */
-(GLKMatrix4*) matrix4ForUniform:(GLK2Uniform*) v inDrawCall:(GLK2DrawCall*) drawCall;

/** Returns FALSE if this object has no value / wants you to leave the value alone, because C doesn't support null primitives */
-(BOOL) floatForUniform:(GLK2Uniform*) v returnIn:(float*) value inDrawCall:(GLK2DrawCall*) drawCall;
/** Returns FALSE if this object has no value / wants you to leave the value alone, because C doesn't support null primitives */
-(BOOL) intForUniform:(GLK2Uniform*) v returnIn:(int*) value inDrawCall:(GLK2DrawCall*) drawCall;

@end

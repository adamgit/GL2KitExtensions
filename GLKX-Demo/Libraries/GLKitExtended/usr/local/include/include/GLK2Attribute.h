/**
 Part 3: ... not published yet ...
 
 Corresponds to an OpenGL 'attribute' item found in a shader source file, e.g.
 
 "mediump attribute vec4 color"
 
 */
#import <Foundation/Foundation.h>

@interface GLK2Attribute : NSObject

+(GLK2Attribute*) attributeNamed:(NSString*) nameOfAttribute GLType:(GLenum) openGLType GLLocation:(GLint) openGLLocation GLSize:(GLint) openGLSize;

/** The name of the variable inside the shader source file(s) */
@property(nonatomic, retain) NSString* nameInSourceFile;

/** The magic key that allows you to "set" this attribute later by uploading a list/array of data to the GPU, e.g. using a VBO */
@property(nonatomic) GLint glLocation;

/** GL ES 2 specifies possible types:
 
 (NB: Desktop GL has *more* types; the complete list is here, but most of them ARE NOT ALLOWED in ES 2: http://www.opengl.org/sdk/docs/man/xhtml/glGetActiveUniform.xml )
 
 BOOLEANS: bool, 2-bool-vector, 3-bool-vector, 4-bool-vector,
 INTEGERS: int, 2-int-vector, 3-int-vector, 4-int-vector,
 FLOATING POINTS: float, 2-float-vector, 3-float-vector, 4-float-vector, 2-matrix, 3-matrix, 4-matrix
 
 ... and the special types: (technically "uniforms" but have special code in OpenGL that treats them differently):
 
 TEXTURES: 2D texture, Cubemap texture
 */
@property(nonatomic) GLenum glType;

/** Defined by OpenGL as "the size of the attribute, in units of the type returned in type."
 
 e.g. if "type" is 4-int-vector, and the attribute was declared as "vec4", then size will be "1".
 
 But (unconfirmed): if the attribute were declared as "vec4[2]", then size would be "2". i.e. "size" really
 means "sizeOfArrayIfThisIsAnArrayOtherwiseOne" - but I've seen it return some unexpected values in the past,
 so CAVEAT EMPTOR.
*/
@property(nonatomic) GLint glSize;

@end

/**
 Part 3: ... not published yet ...
 
 Corresponds to an OpenGL 'attribute' item found in a shader source file, e.g.
 
 "mediump attribute vec4 color"
 
 */
#import <Foundation/Foundation.h>

@interface GLK2Attribute : NSObject

+(GLK2Attribute*) attributeNamed:(NSString*) nameOfAttribute GLType:(GLenum) openGLType GLLocation:(GLint) openGLLocation;

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

@end

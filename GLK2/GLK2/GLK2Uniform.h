/**
 
 **** NB: if you add any properties, make sure you add them to "copyWithZone:" method too
 
 */
#import <Foundation/Foundation.h>

@interface GLK2Uniform : NSObject <NSCopying> /** Apple's design of NSDictionary forces us to 'copy' keys, instead of mapping them */

+(GLK2Uniform*) uniformNamed:(NSString*) nameOfUniform GLType:(GLenum) openGLType GLLocation:(GLint) openGLLocation numElementsInArray:(GLint) numElements;

/** The name of the variable inside the shader source file(s) */
@property(nonatomic, retain) NSString* nameInSourceFile;

/** The magic key that allows you to "set" this uniform later, with a new value every frame (or draw call) */
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

/** A uniform can be an "array of" values, rather than a single value. This is "1" for a single value, or array length otherwise. From GL docs:
 
 "Uniform variables other than arrays
 will have a size of 1. Structures and arrays of structures will
 be reduced as described earlier, such that each of the names
 returned will be a data type in the earlier list. If this
 reduction results in an array, the size returned will be as
 described for uniform arrays; otherwise, the size returned will
 be 1."
 
 */
@property(nonatomic) GLint arrayLength;

#pragma mark - Interpretation of OpenGL's badly-typed "type" feature

@property(nonatomic,readonly) BOOL isInteger, isFloat, isVector, isMatrix;

/** 4x4 matrix returns "4", etc - OpenGL has this info, refuses to provide it, but bizarrely: requires the application to re-submit it */
-(int) matrixWidth;

/** 4x1 vector returns "4", etc - OpenGL has this info, refuses to provide it, but bizarrely: requires the application to re-submit it */
-(int) vectorWidth;

@end

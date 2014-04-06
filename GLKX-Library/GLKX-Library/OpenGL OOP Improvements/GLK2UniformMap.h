/**
 OpenGL is a C-only library. Apple did NOT implement it to be Obj-C compatible.
 
 Mostly this is not a problem, but Shader Uniforms have to be sent as "non-object pointers",
 which causes chaos: none of the Obj-C libraries support this. You are required to
 write some pure-C code to convert ObjC, which is ridiculous (and VERY slow).
 
 This class uses the info we have about Uniforms (that they can only have one of a small number
 of types, each of which is a struct) to construct an efficient and simple solution.
 
 Apple REALLY should have included this in GLKit!
 */
#import <Foundation/Foundation.h>

#import <GLKit/GLKit.h>
#import "GLK2ShaderProgram.h"

#define LOG_WARNINGS_ON_MISSING_UNIFORMS 1

@interface GLK2UniformMap : NSObject

/**
 Allocates precisely the amount of storage needed to hold all uniform names and values
 for the ShaderProgram you provide.
 
 Make sure the shaderProgram is already linked, otherwise it might have NO INFO on which
 uniforms it contains!
 */
+(GLK2UniformMap*) uniformMapForLinkedShaderProgram:(GLK2ShaderProgram*) shaderProgram;

/**
 Allocates precisely the amount of storage needed to hold all uniform names and values
 listed.
 */
- (id)initWithUniforms:(NSArray*) allUniforms;

#pragma mark - methods for setting and getting via pointers
-(GLKMatrix2*) pointerToMatrix2Named:(NSString*) name;
-(GLKMatrix3*) pointerToMatrix3Named:(NSString*) name;
-(GLKMatrix4*) pointerToMatrix4Named:(NSString*) name;
-(void) setMatrix2:(GLKMatrix2) value named:(NSString*) name;
-(void) setMatrix3:(GLKMatrix3) value named:(NSString*) name;
-(void) setMatrix4:(GLKMatrix4) value named:(NSString*) name;

-(GLKVector2*) pointerToVector2Named:(NSString*) name;
-(GLKVector3*) pointerToVector3Named:(NSString*) name;
-(GLKVector4*) pointerToVector4Named:(NSString*) name;
-(void) setVector2:(GLKVector2) value named:(NSString*) name;
-(void) setVector3:(GLKVector3) value named:(NSString*) name;
-(void) setVector4:(GLKVector4) value named:(NSString*) name;

#pragma mark - Primitives

-(GLint*) pointerToIntNamed:(NSString*) name isValid:(BOOL*) isValid;
-(GLfloat*) pointerToFloatNamed:(NSString*) name isValid:(BOOL*) isValid;

@end

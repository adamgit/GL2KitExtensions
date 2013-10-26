/**
 Each drawcall,  you can ask this object to provide values for any/all of the GL Uniforms
 in the current shader program
 */
#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "GLK2Uniform.h"

@interface UniformCalculator : NSObject

-(GLKVector2*) vector2ForUniform:(GLK2Uniform*) v;
-(GLKVector3*) vector3ForUniform:(GLK2Uniform*) v;
-(GLKVector4*) vector4ForUniform:(GLK2Uniform*) v;

-(GLKMatrix2*) matrix2ForUniform:(GLK2Uniform*) v;
-(GLKMatrix3*) matrix3ForUniform:(GLK2Uniform*) v;
-(GLKMatrix4*) matrix4ForUniform:(GLK2Uniform*) v;

-(float) floatForUniform:(GLK2Uniform*) v;

@end

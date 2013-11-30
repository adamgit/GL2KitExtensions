#import "GLK2UniformValueGenerator.h"

@implementation GLK2UniformValueGenerator

-(GLKVector2*) vector2ForUniform:(GLK2Uniform*) v { return NULL; }
-(GLKVector3*) vector3ForUniform:(GLK2Uniform*) v { return NULL; }
-(GLKVector4*) vector4ForUniform:(GLK2Uniform*) v { return NULL; }

-(GLKMatrix2*) matrix2ForUniform:(GLK2Uniform*) v { return NULL; }
-(GLKMatrix3*) matrix3ForUniform:(GLK2Uniform*) v { return NULL; }
-(GLKMatrix4*) matrix4ForUniform:(GLK2Uniform*) v { return NULL; }

-(BOOL) floatForUniform:(GLK2Uniform*) v returnIn:(float*) value { return FALSE; }
-(BOOL) intForUniform:(GLK2Uniform*) v returnIn:(int*) value { return FALSE; }

@end

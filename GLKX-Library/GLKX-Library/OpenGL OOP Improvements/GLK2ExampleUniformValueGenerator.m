#import "GLK2ExampleUniformValueGenerator.h"

@implementation GLK2ExampleUniformValueGenerator

-(GLKVector2*) vector2ForUniform:(GLK2Uniform*) v inDrawCall:(GLK2DrawCall*) drawCall  { return NULL; }
-(GLKVector3*) vector3ForUniform:(GLK2Uniform*) v inDrawCall:(GLK2DrawCall*) drawCall { return NULL; }
-(GLKVector4*) vector4ForUniform:(GLK2Uniform*) v inDrawCall:(GLK2DrawCall*) drawCall { return NULL; }

-(GLKMatrix2*) matrix2ForUniform:(GLK2Uniform*) v inDrawCall:(GLK2DrawCall*) drawCall { return NULL; }
-(GLKMatrix3*) matrix3ForUniform:(GLK2Uniform*) v inDrawCall:(GLK2DrawCall*) drawCall { return NULL; }
-(GLKMatrix4*) matrix4ForUniform:(GLK2Uniform*) v inDrawCall:(GLK2DrawCall*) drawCall { return NULL; }

-(BOOL) floatForUniform:(GLK2Uniform*) v returnIn:(GLfloat*) value inDrawCall:(GLK2DrawCall*) drawCall { return FALSE; }
-(BOOL) intForUniform:(GLK2Uniform*) v returnIn:(GLint*) value inDrawCall:(GLK2DrawCall*) drawCall { return FALSE; }

@end

#import "GLK2UniformMapGenerator.h"

@implementation GLK2UniformMapGenerator

+(GLK2UniformMapGenerator *)generatorForShaderProgram:(GLK2ShaderProgram *)shaderProgram
{
	GLK2UniformMapGenerator* newValue = [[GLK2UniformMapGenerator alloc] initWithUniforms:shaderProgram.allUniforms];
	
	return newValue;
}

+(GLK2UniformMapGenerator *)createAndAddToDrawCall:(GLK2DrawCall *)drawcall
{
	GLK2UniformMapGenerator* newValue = [self generatorForShaderProgram:drawcall.shaderProgram];
	drawcall.uniformValueGenerator = newValue;
	
	return newValue;
}

#pragma mark - Matrices

-(GLKMatrix2*) matrix2ForUniform:(GLK2Uniform*) v inDrawCall:(GLK2DrawCall*) drawCall
{
	return [self pointerToMatrix2Named:v.nameInSourceFile];
}

-(GLKMatrix3*) matrix3ForUniform:(GLK2Uniform*) v inDrawCall:(GLK2DrawCall*) drawCall
{
	return [self pointerToMatrix3Named:v.nameInSourceFile];
}

-(GLKMatrix4 *)matrix4ForUniform:(GLK2Uniform *)v inDrawCall:(GLK2DrawCall *)drawCall
{
	return [self pointerToMatrix4Named:v.nameInSourceFile];
}

#pragma mark - Vectors

-(GLKVector2*) vector2ForUniform:(GLK2Uniform*) v inDrawCall:(GLK2DrawCall*) drawCall
{
	return [self pointerToVector2Named:v.nameInSourceFile];
}

-(GLKVector3*) vector3ForUniform:(GLK2Uniform*) v inDrawCall:(GLK2DrawCall*) drawCall
{
	return [self pointerToVector3Named:v.nameInSourceFile];
}

-(GLKVector4 *)vector4ForUniform:(GLK2Uniform *)v inDrawCall:(GLK2DrawCall *)drawCall
{
	return [self pointerToVector4Named:v.nameInSourceFile];
}

-(BOOL) floatForUniform:(GLK2Uniform*) v returnIn:(float*) value inDrawCall:(GLK2DrawCall*) drawCall
{
	NSAssert(FALSE, @"Storing floats: not implemented yet");
	return FALSE;
}

-(BOOL) intForUniform:(GLK2Uniform*) v returnIn:(GLint*) value inDrawCall:(GLK2DrawCall*) drawCall
{
	BOOL isValid;
	*value = *[self pointerToIntNamed:v.nameInSourceFile isValid:&isValid];
	
	return isValid;
}

@end

/**
 
 */
#import <Foundation/Foundation.h>

#import "GLK2UniformValueGenerator.h"
#import "GLK2UniformMap.h"
#import "GLK2DrawCall.h"

@interface GLK2UniformMapGenerator : GLK2UniformMap <GLK2UniformValueGenerator>

/**
 Generally, you should use createAndAddToDrawCall: instead - that method delegates
 to this one
 */
+(GLK2UniformMapGenerator*) generatorForShaderProgram:(GLK2ShaderProgram*) shaderProgram;

/** Creates a generator for the drawcall's current ShaderProgram, and attaches it
 directly to the DrawCall
 */
+(GLK2UniformMapGenerator *)createAndAddToDrawCall:(GLK2DrawCall *)drawcall;

@end

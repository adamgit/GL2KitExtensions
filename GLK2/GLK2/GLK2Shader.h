/**
 Part 3: ... not published yet ...
 
 The most important method is shaderFromFilename:type:
 */
#import <Foundation/Foundation.h>

#import "GLK2ShaderProgram.h"

/**
 GL ES 2 has exactly two types of shader, but desktop GL has more, and we expect future versions of ES to add them in
 */
typedef enum GLK2ShaderType
{
	GLK2ShaderTypeVertex = GL_VERTEX_SHADER,
	GLK2ShaderTypeFragment = GL_FRAGMENT_SHADER
} GLK2ShaderType;

/**
 Useful for internal sanity checks
 */
typedef enum GLK2ShaderStatus
{
	GLK2ShaderStatusUncompiled,
	GLK2ShaderStatusCompiled,
	GLK2ShaderStatusLinked
} GLK2ShaderStatus;

@interface GLK2Shader : NSObject

/** OpenGL uses integers as "names" instead of Strings, because Strings in C are a pain to work with, and slower */
@property(nonatomic, readonly) GLuint glName;

@property(nonatomic) GLK2ShaderType type;
@property(nonatomic) GLK2ShaderStatus status;

/** Filename for the shader with NO extension; assumes all Vertex shaders end .vsh, all Fragment shaders end .fsh */
@property(nonatomic,retain) NSString* filename;

/** Convenience method that sets up the shader, ready to be compiled */
+(GLK2Shader*) shaderFromFilename:(NSString*) fname type:(GLK2ShaderType) type;

/** Compiles the shader; you have to do setup of a GLK2ShaderProgram / OpenGL ShaderProgram also */
-(void) compile;

@end

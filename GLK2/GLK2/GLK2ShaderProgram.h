/**
 Part 3: ... not published yet ...
 
 ShaderProgram is a boilerplate concept that is REQUIRED to be identical for all OpenGL apps; this class is intended to be
 reused everywhere without changes. A ShaderProgram in OpenGL ES 2 is "1 x vertex shader + 1 x fragment shader, combined into
 a single item".

 (NB: this version is incomplete, a basic implementation only, next version will add a few missing features, and then never
 need to be edited again)
 */
#import <Foundation/Foundation.h>

#import "GLK2Attribute.h"

typedef enum GLK2ShaderProgramStatus
{
	GLK2ShaderProgramStatusUnlinked,
	GLK2ShaderProgramStatusLinked
} GLK2ShaderProgramStatus;

@class GLK2Shader;

@interface GLK2ShaderProgram : NSObject

/**
 
 Does all the work of:
 
 - finding vertex + fragment shaders on disk
 - loading the source code of the shaders
 - compiling them
 - linking them
 - storing post-link info that OpenGL apps MUST have in order to work corectly
 
 */
+(GLK2ShaderProgram*) shaderProgramFromVertexFilename:(NSString*) vFilename fragmentFilename:(NSString*) fFilename;

@property(nonatomic) GLK2ShaderProgramStatus status;

/** OpenGL uses integers as "names" instead of Strings, because Strings in C are a pain to work with, and slower */
@property(nonatomic) GLuint glName;

/** Setting either property automatically calls glAttachShader */
@property(nonatomic,retain) GLK2Shader* vertexShader, * fragmentShader;

/** the "link" stage automatically finds all "attribute" lines in the shader source, and creates one GLK2Attribute for each */
-(GLK2Attribute*) attributeNamed:(NSString*) name;
/** the "link" stage automatically finds all "attribute" lines in the shader source, and creates one GLK2Attribute for each */
-(NSArray*) allAttributes;

/** automatically calls glCreateProgram() */
- (id)init;

@end

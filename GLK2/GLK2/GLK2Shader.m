/**
 Part 3: ... not published yet ...
 */
#import "GLK2Shader.h"

@implementation GLK2Shader

+(GLK2Shader*) shaderFromFilename:(NSString*) fname type:(GLK2ShaderType) type
{
	GLK2Shader* newShader = [[[GLK2Shader alloc]init]autorelease];
	newShader.type = type;
	newShader.filename = fname;
	return newShader;
}

-(void) compile
{
	NSAssert( self.status == GLK2ShaderStatusUncompiled, @"Can't compile; already compiled");
	
	NSString *shaderPathname;
	GLenum glShaderType;
	NSString* stringShaderType;
	
    // Create and compile shader.
	switch( self.type )
	{
		case GLK2ShaderTypeFragment:
		{
			glShaderType = GL_FRAGMENT_SHADER;
			shaderPathname = [[NSBundle mainBundle] pathForResource:self.filename ofType: @"fsh"];
			stringShaderType = @"fragment";
		}break;
			
		case GLK2ShaderTypeVertex:
		{
			glShaderType = GL_VERTEX_SHADER;
			shaderPathname = [[NSBundle mainBundle] pathForResource:self.filename ofType: @"vsh"];
			stringShaderType = @"vertex";
		}break;
	}
	
	
	[GLK2Shader compileShader:&_glName type:glShaderType file:shaderPathname];
	self.status = GLK2ShaderStatusCompiled;
}

+ (void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    NSAssert( source, @"Failed to load shader from file: %@", file);
	
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
    }
}

@end

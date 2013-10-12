/**
 Version 2: ... not published yet ...
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
	
	
	if (![GLK2Shader compileShader:&_glName type:glShaderType file:shaderPathname])
	{
		self.status = GLK2ShaderStatusUncompiled;
		
		GLenum err;
		if( (err = glGetError()) != GL_NO_ERROR )
		{
			NSLog(@"in compiling %@ shader: GL Error: %d", stringShaderType, err );
		}
		
		NSAssert( FALSE, @"Failed to compile %@ shader: %@", stringShaderType, self.filename);
	}
	else
		self.status = GLK2ShaderStatusCompiled;
}

+ (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    NSAssert( source, @"Failed to load shader from file: %@", file);
	if( !source )
		return NO;
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

@end

/**
 Part 3: ... not published yet ...
 */
#import "GLK2Shader.h"

@interface GLK2Shader()
@property(nonatomic, readwrite) GLuint glName;
@end

@implementation GLK2Shader

+(GLK2Shader*) shaderFromFilename:(NSString*) fname type:(GLK2ShaderType) type
{
	GLK2Shader* newShader = [[[GLK2Shader alloc]initWithType:type]autorelease];
	newShader.filename = fname;
	return newShader;
}

- (id)initWithType:(GLK2ShaderType) type
{
    self = [super init];
    if (self) {
		self.type = type;
        self.glName = glCreateShader( self.type );
		
		NSLog(@"[%@] Created new GL shader with GL name = %i", [self class], self.glName );
    }
    return self;
}

-(void)dealloc
{
	self.filename = nil;
	
	/**
	 
	 Do NOT "glDeleteShader" when this deallocs; the way OpenGL committee designed Shaders is incompatible
	 with the rest of GL, and you delete IMMEDIATELY AFTER CREATING, rather than waiting until you stop using it
	 
	 */
	
	[super dealloc];
}

-(void) compile
{
	NSAssert( self.status == GLK2ShaderStatusUncompiled, @"Can't compile; already compiled");
	
	NSString *shaderPathname;
	
	// Create and compile shader.
	switch( self.type )
	{
		case GLK2ShaderTypeFragment:
		{
			self.type = GL_FRAGMENT_SHADER;
			shaderPathname = [[NSBundle mainBundle] pathForResource:self.filename ofType: @"fsh"];
		}break;
			
		case GLK2ShaderTypeVertex:
		{
			self.type = GL_VERTEX_SHADER;
			shaderPathname = [[NSBundle mainBundle] pathForResource:self.filename ofType: @"vsh"];
		}break;
	}
	
    const GLchar *source = (GLchar *)[[NSString stringWithContentsOfFile:shaderPathname encoding:NSUTF8StringEncoding error:nil] UTF8String];
	if( source == 0 )
		@throw [NSException exceptionWithName:@"Shader Compile failure" reason:[NSString stringWithFormat:@"Failed to load shader from file: %@ (using filename:%@)", shaderPathname, self.filename ] userInfo:@{ @"Resolved path":shaderPathname==nil ? [NSNull null] : shaderPathname, @"Original filename":self.filename == nil ? [NSNull null] : self.filename} ];
	
    glShaderSource( self.glName, 1, &source, NULL);
	
	/** Compile it! */
    glCompileShader( self.glName );
    
	/** Check for success - throw exception on failure (failure to compile is VERY bad sign) */
	GLint status;
    glGetShaderiv( self.glName, GL_COMPILE_STATUS, &status);
    if( status == GL_TRUE )
	{
		self.status = GLK2ShaderStatusCompiled;
	}
	else
	{
		NSString* log = [GLK2Shader fetchLogForGLCompileShader:self];
		
		@throw [NSException exceptionWithName:@"Shader Compile failure" reason:[NSString stringWithFormat:@"Compile failure for: %@", shaderPathname ] userInfo:@{ @"filename":shaderPathname, @"Compiler output":log} ];
	}
}

+(NSString*) fetchLogForGLCompileShader:(GLK2Shader*) shader
{
	int loglen;
	char logbuffer[1000];
	glGetShaderInfoLog( shader.glName, sizeof(logbuffer), &loglen, logbuffer);
	
	if (loglen > 0)
	{
		return [NSString stringWithUTF8String:logbuffer];
	}
	else
		return @"";
}

+(NSString*) fetchLogForGLLinkShaderProgram:(GLK2ShaderProgram*) program
{
	int loglen;
	char logbuffer[1000];
	glGetProgramInfoLog(program.glName, sizeof(logbuffer), &loglen, logbuffer);
	if (loglen > 0) {
		return [NSString stringWithUTF8String:logbuffer];
	}
	else
		return @"";
}

@end

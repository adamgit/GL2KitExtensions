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
	
	if (self.glName)
	{
		glDeleteShader(self.glName); // MUST go last (it's used by other things during dealloc side-effects)
		NSLog(@"[%@] dealloc: Deleted GL shader with GL name = %i", [self class], self.glName );
	}
	else
		NSLog(@"[%@] dealloc: NOT deleting GL shader (no GL name)", [self class] );
	
	[super dealloc];
}

-(void) compile
{
	NSAssert( self.status == GLK2ShaderStatusUncompiled, @"Can't compile; already compiled");
	
	NSString *shaderPathname;
	NSString* stringShaderType;
	
    // Create and compile shader.
	switch( self.type )
	{
		case GLK2ShaderTypeFragment:
		{
			self.type = GL_FRAGMENT_SHADER;
			shaderPathname = [[NSBundle mainBundle] pathForResource:self.filename ofType: @"fsh"];
			stringShaderType = @"fragment";
		}break;
			
		case GLK2ShaderTypeVertex:
		{
			self.type = GL_VERTEX_SHADER;
			shaderPathname = [[NSBundle mainBundle] pathForResource:self.filename ofType: @"vsh"];
			stringShaderType = @"vertex";
		}break;
	}
	
    const GLchar *source = (GLchar *)[[NSString stringWithContentsOfFile:shaderPathname encoding:NSUTF8StringEncoding error:nil] UTF8String];
    NSAssert( source, @"Failed to load shader from file: %@", shaderPathname);
	
    glShaderSource( self.glName, 1, &source, NULL);
    glCompileShader( self.glName );
    
	GLint status;
    glGetShaderiv( self.glName, GL_COMPILE_STATUS, &status);
    if( status == GL_TRUE )
	{
		self.status = GLK2ShaderStatusCompiled;
	}
}

@end

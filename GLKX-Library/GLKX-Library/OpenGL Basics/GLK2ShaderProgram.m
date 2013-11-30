#import "GLK2ShaderProgram.h"

#import "GLK2Shader.h"
#import "GLK2Attribute.h"

@interface GLK2ShaderProgram()
@property(nonatomic,retain) NSMutableDictionary * vertexAttributesByName;
@property(nonatomic, readwrite) GLuint glName;
@end

@implementation GLK2ShaderProgram

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


+(GLK2ShaderProgram*) shaderProgramFromVertexFilename:(NSString*) vFilename fragmentFilename:(NSString*) fFilename
{
	GLK2ShaderProgram* newProgram = [[[GLK2ShaderProgram alloc] init] autorelease];
	
	GLK2Shader* vertexShader = [GLK2Shader shaderFromFilename:vFilename type:GLK2ShaderTypeVertex];
	GLK2Shader* fragmentShader = [GLK2Shader shaderFromFilename:fFilename type:GLK2ShaderTypeFragment];
	
	@try
	{
		// Attach shader to program.
		[vertexShader compile];
		[fragmentShader compile];
		newProgram.vertexShader = vertexShader;
		newProgram.fragmentShader = fragmentShader;
		
		/** GL spec: "link" */
		[newProgram link];
		
	}
	@catch (NSException *exception) {
		NSLog(@"Exception trying to compile / link shaders:\n %@ : %@", exception, [exception userInfo] );
		@throw exception;
	}
	@finally {
	}
	
	return newProgram;
}

- (id)init
{
    self = [super init];
    if (self)
	{
        self.glName = glCreateProgram();
		self.vertexAttributesByName = [NSMutableDictionary dictionary];
		
		NSLog(@"[%@] Created new GL program with GL name = %i", [self class], self.glName );
    }
    return self;
}

-(void)dealloc
{
	self.vertexShader = nil;
	self.fragmentShader = nil;
	self.vertexAttributesByName = nil;
	
	if (self.glName)
	{
		glDeleteProgram(self.glName); // MUST go last (it's used by other things during dealloc side-effects)
		NSLog(@"[%@] dealloc: Deleted GL program with GL name = %i", [self class], self.glName );
	}
	else
		NSLog(@"[%@] dealloc: NOT deleting GL program (no GL name)", [self class] );
	
	[super dealloc];
}

-(void)setFragmentShader:(GLK2Shader *)fragmentShader
{
	if( fragmentShader == _fragmentShader )
		return;
	
	NSAssert( fragmentShader == nil || _fragmentShader == nil, @"Fragment shader can only be assigned once: either it must be nil to start with, or you have to be assigning to nil now because the ShaderProgram is dealloc'ing");
	
	[_fragmentShader release];
	_fragmentShader = fragmentShader;
	[_fragmentShader retain];
	
	/** react */
	if( _fragmentShader != nil )
		glAttachShader( self.glName, fragmentShader.glName );
}

-(void)setVertexShader:(GLK2Shader *)vertexShader
{
	if( vertexShader == _vertexShader )
		return;
	
	NSAssert( vertexShader == nil || _vertexShader == nil, @"Vertex shader can only be assigned once: either it must be nil to start with, or you have to be assigning to nil now because the ShaderProgram is dealloc'ing");
	
	[_vertexShader release];
	_vertexShader = vertexShader;
	[_vertexShader retain];
	
	/** react */
	if( _vertexShader != nil )
		glAttachShader( self.glName, _vertexShader.glName );
}

/** OpenGL spec is poorly designed and makes this a wordy chunk of boilerplate code that
 has to be repeated at least twice in your app
 */
-(NSMutableDictionary*) fetchAllAttributesAfterLinking
{
	NSMutableDictionary* result = [[NSMutableDictionary new] autorelease];
	
	/********************************************************************
	 *
	 * Query OpenGL for the data on all the "Attributes" (anything
	 * in your shader source files that has type "attribute")
	 */
	/** Allocate enough memory to store the string name of each uniform
	 (OpenGL is a C API. C is a horrible, dead language. Deal with it)
	 */
	GLint numCharactersInLongestName;
	glGetProgramiv( self.glName, GL_ACTIVE_ATTRIBUTE_MAX_LENGTH, &numCharactersInLongestName);
	char* nextAttributeName = malloc( sizeof(char) * numCharactersInLongestName );
	
	/** how many attributes did OpenGL find? */
	GLint numAttributesFound;
	glGetProgramiv( self.glName, GL_ACTIVE_ATTRIBUTES, &numAttributesFound);
	
#if DEBUG
	NSLog(@"[%@] ---- WARNING: this is not recommended; I am implementing it to check it works, but you should very rarely use glGetActiveAttrib - instead you should be using an explicit glBindAttribLoction BEFORE linking", [self class]);
#endif
	/** iterate through all the attributes found, and store them on CPU somewhere */
	for( int i = 0; i < numAttributesFound; i++ )
	{
		GLint attributeLocation, attributeSize;
		GLenum attributeType;
		NSString* stringName; // converted from GL C string, for use in standard ObjC calls and classes
		
		/** From two items: the glProgram object, and the text/string of attribute-name ... we get all other data, using 2 calls */
		glGetActiveAttrib( self.glName, i, numCharactersInLongestName, NULL /**length of string written to final arg; not needed*/, &attributeSize, &attributeType, nextAttributeName );
		
		attributeLocation = glGetAttribLocation( self.glName, nextAttributeName );
		stringName = [NSString stringWithUTF8String:nextAttributeName];
		
		GLK2Attribute* newAttribute = [GLK2Attribute attributeNamed:stringName GLType:attributeType GLLocation:attributeLocation GLSize:attributeSize];
		
		[result setObject:newAttribute forKey:stringName];
#if DEBUG
		NSLog(@"Stored attribute: '%@' with location: %i", stringName, attributeLocation );
#endif
	}
	
	free( nextAttributeName );
	
	return result;
}

-(void) link
{
    // Link program.
    [GLK2ShaderProgram linkProgram: self];
	self.status = GLK2ShaderProgramStatusLinked;
	
	self.vertexShader.status = GLK2ShaderStatusLinked;
	self.fragmentShader.status = GLK2ShaderStatusLinked;
	
    // Release vertex and fragment shaders.
    if ( self.vertexShader) {
        glDetachShader( self.glName, self.vertexShader.glName );
        glDeleteShader( self.vertexShader.glName ); // OpenGL will 'retain' internally according to spec
    }
    if ( self.fragmentShader) {
        glDetachShader( self.glName, self.fragmentShader.glName );
        glDeleteShader( self.fragmentShader.glName ); // OpenGL will 'retain' internally according to spec
    }
	
	self.vertexAttributesByName = [self fetchAllAttributesAfterLinking];
}

-(void) validate
{
#if DEBUG
	glValidateProgram( self.glName );
	
	NSString* validationOutput = [GLK2ShaderProgram fetchLogForGLLinkShaderProgram:self];
	if( validationOutput.length > 0 )
	{
#define VALIDATION_FAILURE_TRIGGERS_EXCEPTION 1
#if VALIDATION_FAILURE_TRIGGERS_EXCEPTION
		@throw [NSException exceptionWithName:@"ShaderProgram Validation failure" reason:@"Validate failure" userInfo:@{ @"Validater output":validationOutput } ];
#else
		NSLog( @"ShaderProgram Validation failure: %@", validationOutput );
#endif
	}
#else
	NSLog( @"MAJOR ERROR: you are calling GLSL 'validate' in a production app; this is very dangerous. Apple's drivers do some crazy stuff in here, including gigabytes of memory usage, FAILS on working code, etc. This should ONLY be used as a debug tool" );
#endif
}

#pragma mark - runtime methods for application to use

-(GLK2Attribute*) attributeNamed:(NSString*) name
{
	return [self.vertexAttributesByName objectForKey:name];
}

-(NSArray*) allAttributes
{
	return [self.vertexAttributesByName allValues];
}


#pragma mark - OpenGL low-level invocations

+(void) linkProgram:(GLK2ShaderProgram*) program
{
    GLint status;
    glLinkProgram(program.glName);
    
    glGetProgramiv(program.glName, GL_LINK_STATUS, &status);
	
	if( status == GL_FALSE )
		@throw [NSException exceptionWithName:@"ShaderProgram Link failure" reason:@"Link failure" userInfo:@{ @"Linker output":[self fetchLogForGLLinkShaderProgram:program] } ];
}

@end

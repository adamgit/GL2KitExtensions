#import "GLK2ShaderProgram.h"

#import "GLK2Shader.h"
#import "GLK2Uniform.h"
#import "GLK2Attribute.h"

@interface GLK2ShaderProgram()
@property(nonatomic,retain) NSMutableDictionary* uniformVariablesByName, * vertexAttributesByName;
@end

@implementation GLK2ShaderProgram

+(GLK2ShaderProgram*) shaderProgramFromVertexFilename:(NSString*) vFilename fragmentFilename:(NSString*) fFilename
{
	GLK2ShaderProgram* newProgram = [[[GLK2ShaderProgram alloc] init] autorelease];

	GLK2Shader* vertexShader = [GLK2Shader shaderFromFilename:vFilename type:GLK2ShaderTypeVertex];
	GLK2Shader* fragmentShader = [GLK2Shader shaderFromFilename:fFilename type:GLK2ShaderTypeFragment];
	
	// Attach shader to program.
	[vertexShader compile];
	[fragmentShader compile];
	newProgram.vertexShader = vertexShader;
	newProgram.fragmentShader = fragmentShader;
	
	/** GL spec: "link" */
	[newProgram link];
	
	return newProgram;
}

- (id)init
{
    self = [super init];
    if (self)
	{
        self.glName = glCreateProgram();
		self.uniformVariablesByName = [NSMutableDictionary dictionary];
		self.vertexAttributesByName = [NSMutableDictionary dictionary];
		
		{ // check and reset GL ERROR
			GLenum glErrorCapture;
			while( (glErrorCapture = glGetError()) != GL_NO_ERROR ) // GL spec says you must do this in a WHILE loop
			{
				NSDictionary* glErrorNames = @{ @(GL_INVALID_ENUM) : @"GL_INVALID_ENUM", @(GL_INVALID_VALUE) : @"GL_INVALID_VALUE", @(GL_INVALID_OPERATION) : @"GL_INVALID_OPERATION",  @(GL_OUT_OF_MEMORY) : @"GL_OUT_OF_MEMORY" };
				
				NSLog(@"GL Error: %@", [glErrorNames objectForKey:@(glErrorCapture)] );
				
				{
					NSLog(@"About to assert. Apple doesnt print stacktraces any more. Here it is: %@", [NSThread callStackSymbols] );
					NSAssert(FALSE, @"Hit a GL Error, asserting...");
				}
			}
		}
		
		NSLog(@"[%@] Created new GL program with GL name = %i", [self class], self.glName );
    }
    return self;
}

-(void)dealloc
{
	self.vertexShader = nil;
	self.fragmentShader = nil;
	self.uniformVariablesByName = nil;
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
	
	if( _fragmentShader != nil )
		glDetachShader( self.glName, _fragmentShader.glName );
		
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
	
	if( _vertexShader != nil )
		glDetachShader( self.glName, _vertexShader.glName );
	
	[_vertexShader release];
	_vertexShader = vertexShader;
	[_vertexShader retain];
	
	/** react */
	if( _vertexShader != nil )
		glAttachShader( self.glName, _vertexShader.glName );
}

-(void) link
{
	NSAssert( self.vertexShader.status == GLK2ShaderStatusCompiled, @"You have to compile your shaders before you link your program");
	NSAssert( self.fragmentShader.status == GLK2ShaderStatusCompiled, @"You have to compile your shaders before you link your program");
	
	{ // check and reset GL ERROR
	GLenum glErrorCapture;
	while( (glErrorCapture = glGetError()) != GL_NO_ERROR ) // GL spec says you must do this in a WHILE loop
	{
		NSDictionary* glErrorNames = @{ @(GL_INVALID_ENUM) : @"GL_INVALID_ENUM", @(GL_INVALID_VALUE) : @"GL_INVALID_VALUE", @(GL_INVALID_OPERATION) : @"GL_INVALID_OPERATION",  @(GL_OUT_OF_MEMORY) : @"GL_OUT_OF_MEMORY" };
		
		NSLog(@"GL Error: %@", [glErrorNames objectForKey:@(glErrorCapture)] );
		
		{
			NSLog(@"About to assert. Apple doesnt print stacktraces any more. Here it is: %@", [NSThread callStackSymbols] );
			NSAssert(FALSE, @"Hit a GL Error, asserting...");
		}
	}
	}
	
    // Link program.
    if (![GLK2ShaderProgram linkProgram: self.glName])
	{
        NSLog(@"Failed to link program");
        
		self.status = GLK2ShaderProgramStatusUnlinked;
    }
	else
	{
		self.status = GLK2ShaderProgramStatusLinked;
		
		self.vertexShader.status = GLK2ShaderStatusLinked;
		self.fragmentShader.status = GLK2ShaderStatusLinked;
	}

    // Release vertex and fragment shaders.
    if ( self.vertexShader) {
        glDetachShader( self.glName, self.vertexShader.glName );
        glDeleteShader( self.vertexShader.glName ); // OpenGL will 'retain' internally according to spec
    }
    if ( self.fragmentShader) {
        glDetachShader( self.glName, self.fragmentShader.glName );
        glDeleteShader( self.fragmentShader.glName ); // OpenGL will 'retain' internally according to spec
    }
	
	/********************************************************************
	 *
	 * Query OpenGL for the data on all the "Uniforms" (anything
	 * in your shader source files that has type "uniform")
	 */
	/** Allocate enough memory to store the string name of each uniform
	 (OpenGL is a C API. C is a horrible, dead language. Deal with it)
	 */
	GLint numCharactersInLongestName;
	glGetProgramiv( self.glName, GL_ACTIVE_UNIFORM_MAX_LENGTH, &numCharactersInLongestName);
	char* nextUniformName = malloc( sizeof(char) * numCharactersInLongestName );
	
	/** how many uniforms did OpenGL find? */
	GLint numUniformsFound;
	glGetProgramiv( self.glName, GL_ACTIVE_UNIFORMS, &numUniformsFound);
	
	/** iterate through all the uniforms found, and store them on CPU somewhere */
	for( int i = 0; i < numUniformsFound; i++ )
	{
		GLint uniformSize, uniformLocation;
		GLenum uniformType;
		NSString* stringName; // converted from GL C string, for use in standard ObjC calls and classes
		
		/** From two items: the glProgram object, and the text/string of uniform-name ... we get all other data, using 2 calls */
		glGetActiveUniform( self.glName, i, numCharactersInLongestName, NULL /**length of string written to final arg; not needed*/, &uniformSize, &uniformType, nextUniformName );
		uniformLocation = glGetUniformLocation( self.glName, nextUniformName );
		stringName = [NSString stringWithUTF8String:nextUniformName];
		
		GLK2Uniform* newUniform = [GLK2Uniform uniformNamed:stringName GLType:uniformType GLLocation:uniformLocation numElementsInArray:uniformSize];
		
		[self.uniformVariablesByName setObject:newUniform forKey:stringName];
	}
	
	free(nextUniformName);
	
	/********************************************************************
	 *
	 * Query OpenGL for the data on all the "Attributes" (anything
	 * in your shader source files that has type "attribute")
	 */
	/** Allocate enough memory to store the string name of each uniform
	 (OpenGL is a C API. C is a horrible, dead language. Deal with it)
	 */
	glGetProgramiv( self.glName, GL_ACTIVE_ATTRIBUTE_MAX_LENGTH, &numCharactersInLongestName);
	char* nextAttributeName = malloc( sizeof(char) * numCharactersInLongestName );
	
	/** how many attributes did OpenGL find? */
	GLint numAttributesFound;
	glGetProgramiv( self.glName, GL_ACTIVE_ATTRIBUTES, &numAttributesFound);
	
	{ // check and reset GL ERROR
		GLenum glErrorCapture;
		while( (glErrorCapture = glGetError()) != GL_NO_ERROR ) // GL spec says you must do this in a WHILE loop
		{
			NSDictionary* glErrorNames = @{ @(GL_INVALID_ENUM) : @"GL_INVALID_ENUM", @(GL_INVALID_VALUE) : @"GL_INVALID_VALUE", @(GL_INVALID_OPERATION) : @"GL_INVALID_OPERATION",  @(GL_OUT_OF_MEMORY) : @"GL_OUT_OF_MEMORY" };
			
			NSLog(@"GL Error: %@", [glErrorNames objectForKey:@(glErrorCapture)] );
			
			{
				NSLog(@"About to assert. Apple doesnt print stacktraces any more. Here it is: %@", [NSThread callStackSymbols] );
				NSAssert(FALSE, @"Hit a GL Error, asserting...");
			}
		}
	}
	
	NSLog(@"[%@] ---- WARNING: this is not recommended; I am implementing it to check it works, but you should very rarely use glGetActiveAttrib - instead you should be using an explicit glBindAttribLoction BEFORE linking", [self class]);
	/** iterate through all the attributes found, and store them on CPU somewhere */
	for( int i = 0; i < numAttributesFound; i++ )
	{
		GLint attributeLocation, attributeSize;
		GLenum attributeType;
		NSString* stringName; // converted from GL C string, for use in standard ObjC calls and classes
		
		/** From two items: the glProgram object, and the text/string of attribute-name ... we get all other data, using 2 calls */
		glGetActiveAttrib( self.glName, i, numCharactersInLongestName, NULL /**length of string written to final arg; not needed*/, &attributeSize, &attributeType, nextAttributeName );
		
		{ // check and reset GL ERROR
			GLenum glErrorCapture;
			while( (glErrorCapture = glGetError()) != GL_NO_ERROR ) // GL spec says you must do this in a WHILE loop
			{
				NSDictionary* glErrorNames = @{ @(GL_INVALID_ENUM) : @"GL_INVALID_ENUM", @(GL_INVALID_VALUE) : @"GL_INVALID_VALUE", @(GL_INVALID_OPERATION) : @"GL_INVALID_OPERATION",  @(GL_OUT_OF_MEMORY) : @"GL_OUT_OF_MEMORY" };
				
				NSLog(@"GL Error: %@", [glErrorNames objectForKey:@(glErrorCapture)] );
				
				{
					NSLog(@"About to assert. Apple doesnt print stacktraces any more. Here it is: %@", [NSThread callStackSymbols] );
					NSAssert(FALSE, @"Hit a GL Error, asserting...");
				}
			}
		}
		
		//NSAssert( attributeSize == 1, @"Unsupported: multi-length shader-attribute variables; I've never seen one, and don't even know what they mean");
		attributeLocation = glGetAttribLocation( self.glName, nextAttributeName );
		stringName = [NSString stringWithUTF8String:nextAttributeName];
		
		GLK2Attribute* newAttribute = [GLK2Attribute attributeNamed:stringName GLType:attributeType GLLocation:attributeLocation];
		
		[self.vertexAttributesByName setObject:newAttribute forKey:stringName];
	}
	
	free( nextAttributeName );
}

-(void) setBooleanBasedValue:(GLboolean*) valuePointer forUniform:(GLK2Uniform*) uniform
{
	switch( uniform.glType )
	{
		/** the basic datatypes first */
		case GL_BOOL:
		{
			glUniform1i( uniform.glLocation, *valuePointer );
		}break;
			
		/** 2 + 3 + 4 element vectors */
		case GL_BOOL_VEC2:
		{
			glUniform2iv( uniform.glLocation, uniform.arrayLength, valuePointer );
		}break;
		case GL_BOOL_VEC3:
		{
			glUniform3iv( uniform.glLocation, uniform.arrayLength, valuePointer );
		}break;
		case GL_BOOL_VEC4:
		{
			glUniform4iv( uniform.glLocation, uniform.arrayLength, valuePointer );
		}break;
			
		default:
		{
			NSAssert( FALSE, @"Impossible glType: %i", uniform.glType );
		}
	}
}

-(void) setIntBasedValue:(GLint*) valuePointer forUniform:(GLK2Uniform*) uniform
{
	switch( uniform.glType )
	{
			/** the basic datatypes first */
		case GL_INT:
		{
			glUniform1i( uniform.glLocation, *valuePointer );
		}break;
			
			/** 2 + 3 + 4 element vectors */
		case GL_INT_VEC2:
		{
			glUniform2iv( uniform.glLocation, uniform.arrayLength, valuePointer );
		}break;
		case GL_INT_VEC3:
		{
			glUniform3iv( uniform.glLocation, uniform.arrayLength, valuePointer );
		}break;
		case GL_INT_VEC4:
		{
			glUniform4iv( uniform.glLocation, uniform.arrayLength, valuePointer );
		}break;
			
		default:
		{
			NSAssert( FALSE, @"Impossible glType: %i", uniform.glType );
		}
	}
}

-(void) setFloatBasedValue:(GLfloat*) valuePointer forUniform:(GLK2Uniform*) uniform transposeMatrix:(BOOL) shouldTranspose
{
	{ // check and reset GL ERROR
		GLenum glErrorCapture;
		while( (glErrorCapture = glGetError()) != GL_NO_ERROR ) // GL spec says you must do this in a WHILE loop
		{
			NSDictionary* glErrorNames = @{ @(GL_INVALID_ENUM) : @"GL_INVALID_ENUM", @(GL_INVALID_VALUE) : @"GL_INVALID_VALUE", @(GL_INVALID_OPERATION) : @"GL_INVALID_OPERATION",  @(GL_OUT_OF_MEMORY) : @"GL_OUT_OF_MEMORY" };
			
			NSLog(@"GL Error: %@", [glErrorNames objectForKey:@(glErrorCapture)] );
			
			{
				NSLog(@"About to assert. Apple doesnt print stacktraces any more. Here it is: %@", [NSThread callStackSymbols] );
				NSAssert(FALSE, @"Hit a GL Error, asserting...");
			}
		}
	}
	
	switch( uniform.glType )
	{
		/** the basic datatypes first */
		case GL_FLOAT:
		{
			glUniform1f( uniform.glLocation, *valuePointer );
		}break;
			
		/** 2 + 3 + 4 element vectors */
		case GL_FLOAT_VEC2:
		{
			glUniform2fv( uniform.glLocation, uniform.arrayLength, valuePointer );
		}break;
		case GL_FLOAT_VEC3:
		{
			glUniform3fv( uniform.glLocation, uniform.arrayLength, valuePointer );
		}break;
		case GL_FLOAT_VEC4:
		{
			glUniform4fv( uniform.glLocation, uniform.arrayLength, valuePointer );
		}break;
			
		/** Floats ONLY: 2 + 3 + 4 width matrices */
		case GL_FLOAT_MAT2:
		{
			glUniformMatrix2fv( uniform.glLocation, uniform.arrayLength, shouldTranspose, valuePointer );
		}break;
		case GL_FLOAT_MAT3:
		{
			glUniformMatrix3fv( uniform.glLocation, uniform.arrayLength, shouldTranspose, valuePointer );
		}break;
		case GL_FLOAT_MAT4:
		{
			glUniformMatrix4fv( uniform.glLocation, uniform.arrayLength, shouldTranspose, valuePointer );
		}break;
			
		default:
		{
			NSAssert( FALSE, @"Impossible glType: %i", uniform.glType );
		}
	}
	
	{ // check and reset GL ERROR
		GLenum glErrorCapture;
		while( (glErrorCapture = glGetError()) != GL_NO_ERROR ) // GL spec says you must do this in a WHILE loop
		{
			NSDictionary* glErrorNames = @{ @(GL_INVALID_ENUM) : @"GL_INVALID_ENUM", @(GL_INVALID_VALUE) : @"GL_INVALID_VALUE", @(GL_INVALID_OPERATION) : @"GL_INVALID_OPERATION",  @(GL_OUT_OF_MEMORY) : @"GL_OUT_OF_MEMORY" };
			
			NSLog(@"GL Error: %@", [glErrorNames objectForKey:@(glErrorCapture)] );
			
			{
				NSLog(@"About to assert. Apple doesnt print stacktraces any more. Here it is: %@", [NSThread callStackSymbols] );
				NSAssert(FALSE, @"Hit a GL Error, asserting...");
			}
		}
	}
}

#pragma mark - runtime methods for application to use

-(GLK2Uniform*) uniformNamed:(NSString*) name
{
	return [self.uniformVariablesByName objectForKey:name];
}

-(GLK2Attribute*) attributeNamed:(NSString*) name
{
	return [self.vertexAttributesByName objectForKey:name];
}

-(NSArray*) allUniforms
{
	return [self.uniformVariablesByName allValues];
}

-(NSArray*) allAttributes
{
	return [self.vertexAttributesByName allValues];
}

-(void) setValue:(const GLfloat*) value forUniform:(GLK2Uniform*) uniform
{
	switch( uniform.glType )
	{
		case GL_FLOAT:
		case GL_FLOAT_VEC2:
		case GL_FLOAT_VEC3:
		case GL_FLOAT_VEC4:
		case GL_FLOAT_MAT2:
		case GL_FLOAT_MAT3:
		case GL_FLOAT_MAT4:
		{
			[self setFloatBasedValue:value forUniform:uniform transposeMatrix:FALSE];
		}
			
		case GL_INT:
		case GL_INT_VEC2:
		case GL_INT_VEC3:
		case GL_INT_VEC4:
		{
			[self setIntBasedValue:value forUniform:uniform];
		}
			
		case GL_BOOL:
		case GL_BOOL_VEC2:
		case GL_BOOL_VEC3:
		case GL_BOOL_VEC4:
		{
			[self setBoolBasedValue:value forUniform:uniform];
		}
			
		default:
			NSAssert(FALSE, @"Uniform %@ has an unknown / unsupported type in shader source file", uniform.nameInSourceFile );
	}
}


#pragma mark - OpenGL low-level invocations

+ (BOOL)linkProgram:(GLuint) programRef
{
    GLint status;
    glLinkProgram(programRef);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(programRef, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(programRef, logLength, &logLength, log);
        NSLog(@"Program link log:w\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(programRef, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

+ (BOOL)validateProgram:(GLuint) programRef
{
    GLint logLength, status;
    
    glValidateProgram(programRef);
    glGetProgramiv(programRef, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(programRef, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(programRef, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}


@end

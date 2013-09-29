#import "GLK2ShaderProgram.h"

#import "GLK2Shader.h"
#import "GLK2Attribute.h"

@interface GLK2ShaderProgram()
@property(nonatomic,retain) NSMutableDictionary * vertexAttributesByName;
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
    // Link program.
    [GLK2ShaderProgram linkProgram: self.glName];
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
	
	NSLog(@"[%@] ---- WARNING: this is not recommended; I am implementing it to check it works, but you should very rarely use glGetActiveAttrib - instead you should be using an explicit glBindAttribLoction BEFORE linking", [self class]);
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
		
		GLK2Attribute* newAttribute = [GLK2Attribute attributeNamed:stringName GLType:attributeType GLLocation:attributeLocation];
		
		[self.vertexAttributesByName setObject:newAttribute forKey:stringName];
	}
	
	free( nextAttributeName );
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

+(void) linkProgram:(GLuint) programRef
{
    GLint status;
    glLinkProgram(programRef);
    
    glGetProgramiv(programRef, GL_LINK_STATUS, &status);
}

@end

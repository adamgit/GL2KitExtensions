/**
 
 */
#import "GLK2Texture.h"

#import "GLK2Texture_MutableName.h"

#import "GLK2TextureLoaderPVRv1.h" // for textureNamed: auto-loading PVR's without Apple's bug

@implementation GLK2Texture

+(GLK2Texture *)textureNewEmpty
{
	GLK2Texture* newValue = [[GLK2Texture new] autorelease];
	
	return newValue;
}

+(GLK2Texture *)texturePreLoadedByApplesGLKit:(GLKTextureInfo *)appleMetadata
{
	GLK2Texture* newValue = [[[GLK2Texture alloc] initWithName:appleMetadata.name] autorelease];
	
	return newValue;
}

+(GLK2Texture *)textureFromNSData:(NSData *)rawData pixelsWide:(int) pWide pixelsHigh:(int) pHigh
{
	GLK2Texture* newValue = [self textureNewEmpty];
	
	[newValue uploadFromNSData:rawData pixelsWide:pWide pixelsHigh:pHigh];
	
	return newValue;
}

+(GLK2Texture *)textureNamed:(NSString *)filename
{
	NSString* guessedPath = nil;
	
	/** if it already has an extension, try it */
	if( [filename pathExtension] != nil )
		guessedPath = [[NSBundle mainBundle] pathForResource:[filename stringByDeletingPathExtension] ofType:[filename pathExtension]];
	
	if( guessedPath == nil )
	{
	NSArray* possibleExtensions = @[ @"png", @"jpg", @"gif", @"pvr" ];
	for( NSString* extension in possibleExtensions )
	{
		if( [[filename pathExtension] isEqualToString:extension] )
		{
			filename = [filename stringByDeletingPathExtension];
			break;
		}
	}
	
	for( NSString* extension in possibleExtensions )
	{
		guessedPath = [[NSBundle mainBundle] pathForResource:filename ofType:extension];
		if( guessedPath != nil )
			break;
	}
	}
	
	NSAssert( guessedPath != nil, @"Failed to find a texture with base filename '%@' and no extension (Apple doesn't allow them)", filename);
	
	NSError* error;
	
	if( [guessedPath hasSuffix:@"pvr"]) // Apple's loader is broken for mipmaps; MUST use custom loader here:
	{
		NSLog(@"using special PVR loader");
		GLK2Texture* newTexture;
		
		newTexture = [GLK2TextureLoaderPVRv1 pvrTextureWithContentsOfFile:guessedPath];
		
		return newTexture;
	}
	else // use apple's GLKit loader (which has many bugs, including some they refuse to fix!)
	{
		GLKTextureInfo* appleTexture = [GLKTextureLoader textureWithContentsOfFile:guessedPath options:nil error:&error];
		
		if( appleTexture == nil )
			NSLog(@"Failed to load texture using Apple's buggy texture loader; error message (usually wrong!) from Apple: %@", error );
		
		NSAssert( appleTexture != nil, @"Failed to load a texture using Apple's texture loader, with base filename '%@' and no extension", filename);
		
		return [self texturePreLoadedByApplesGLKit:appleTexture];
	}
}

- (id)init
{
	GLuint newName;
	glGenTextures(1, &newName);
	
	return [self initWithName:newName];
}

- (id)initWithName:(GLuint) name
{
    self = [super init];
    if (self) {
        self.glName = name;
		self.willDeleteOnDealloc = TRUE;
    }
    return self;
}

- (void)dealloc
{
	
	if( self.willDeleteOnDealloc )
	{
		NSLog(@"Dealloc: %@, glDeleteTexures( 1, %i)", [self class], self.glName );
		glDeleteTextures(1, &_glName);
	}
	
	[super dealloc];
}

-(void) uploadFromNSData:(NSData *)rawData pixelsWide:(int) pWide pixelsHigh:(int) pHigh
{
	/*************** 2. Upload NSData to OpenGL */
	glBindTexture( GL_TEXTURE_2D, self.glName);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, pWide, pHigh, 0, GL_RGBA, GL_UNSIGNED_BYTE, [rawData bytes]);
}

@end

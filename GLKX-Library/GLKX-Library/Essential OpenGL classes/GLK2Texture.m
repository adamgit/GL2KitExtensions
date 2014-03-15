/**
 
 */
#import "GLK2Texture.h"

#import "GLK2Texture_MutableName.h"

#import "GLK2TextureLoaderPVRv1.h" // for textureNamed: auto-loading PVR's without Apple's bug

#if USE_GLK2TEXTURETRACKER_INTERNALLY
#import "GLK2TextureTracker.h"
#endif

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

+(GLK2Texture*) textureAlreadyOnGPUWithName:(GLuint) existingName
{
	GLK2Texture* newValue = [[[GLK2Texture alloc] initWithName:existingName] autorelease];
	
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

/** DESIGNATED INITIALIZER: MUST BE CALLED EVENTUALLY, or else GLK2TextureTracker etc will break */
- (id)initWithName:(GLuint) name
{
    self = [super init];
    if (self) {
        self.glName = name;
		
#if USE_GLK2TEXTURETRACKER_INTERNALLY
		[[GLK2TextureTracker sharedInstance] classTextureCreated:self];
#endif
    }
    return self;
}

- (void)dealloc
{
#if USE_GLK2TEXTURETRACKER_INTERNALLY
	[[GLK2TextureTracker sharedInstance] classTextureDeallocing:self];
	
	// no need to glDeleteTextures - the GLK2TextureTracker will do that *IF* required
#else
	if( self.willDeleteOnDealloc )
	{
		NSLog(@"Dealloc: %@, glDeleteTexures( 1, %i)", [self class], self.glName );
		glDeleteTextures(1, &_glName);
	}
#endif
	
	[super dealloc];
}

-(void)setDisableAutoDelete:(BOOL)newValue
{
	if( _disableAutoDelete == newValue )
		return;
	
	_disableAutoDelete = newValue;
	
#if USE_GLK2TEXTURETRACKER_INTERNALLY
	if( self.disableAutoDelete )
	{
		// create an artificial thing to keep it live
		[[GLK2TextureTracker sharedInstance] gpuTextureArtificiallyRetain:self.glName retainer:self];
	}
	else
	{
		// REMOVE an artificial thing to keep it live
		[[GLK2TextureTracker sharedInstance] gpuTextureStopArtificiallyRetaining:self.glName retainer:self];
	}
#endif
}

-(NSString *)description
{
	return [NSString stringWithFormat:@"Texture-%i%@", self.glName, self.disableAutoDelete? @"(WILL NEVER DELETE)" : @"" ];
}

-(void) uploadFromNSData:(NSData *)rawData pixelsWide:(int) pWide pixelsHigh:(int) pHigh
{
	/*************** 2. Upload NSData to OpenGL */
	glBindTexture( GL_TEXTURE_2D, self.glName);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, pWide, pHigh, 0, GL_RGBA, GL_UNSIGNED_BYTE, [rawData bytes]);
}

-(void) reAssociateWithNewGPUTexture:(GLuint) newTextureName
{
	if( newTextureName == self.glName )
		return; // no effect
	
#if USE_GLK2TEXTURETRACKER_INTERNALLY
	[[GLK2TextureTracker sharedInstance] classTexture:self switchingFrom:self.glName toNew:newTextureName];
#endif
	
	self.glName = newTextureName;
}

-(void)setWrapSClamp
{
	glBindTexture( GL_TEXTURE_2D, self.glName);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
}
-(void)setWrapTClamp
{
	glBindTexture( GL_TEXTURE_2D, self.glName);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
}

-(void)setWrapSRepeat
{
	NSLog(@"Warning: GL ES is broken and makes wrap-S textures go all black if NPOT - but provides NO WAY to check if a texture is NPOT. Seriously bad API design");
	
	glBindTexture( GL_TEXTURE_2D, self.glName);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
}
-(void)setWrapTRepeat
{
	NSLog(@"Warning: GL ES is broken and makes wrap-S textures go all black if NPOT - but provides NO WAY to check if a texture is NPOT. Seriously bad API design");
	
	glBindTexture( GL_TEXTURE_2D, self.glName);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
}

@end

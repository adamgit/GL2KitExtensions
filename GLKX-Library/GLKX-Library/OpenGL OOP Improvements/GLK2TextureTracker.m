#import "GLK2TextureTracker.h"

#import "GLK2TextureTracker_UnitTesting.h" // private methods for unit testing

#define kUNKNOWN_SOURCE_NEVER_DELETE_TEXTURE (@"kUNKNOWN_SOURCE_NEVER_DELETE_TEXTURE")
#define kUNKNOWN_SOURCE_NORMAL (@"kUNKNOWN_SOURCE_NORMAL")

@interface GLK2TextureTracker ()
@property(nonatomic,retain) NSMutableDictionary* thingsReferringToGPUTextures;
@property(nonatomic,retain) NSMutableDictionary* glContextsForEachGPUTexture;
@end

@implementation GLK2TextureTracker
{
	BOOL isDeallocing;
}

static GLK2TextureTracker* staticInstance;
+(GLK2TextureTracker *)sharedInstance
{
	if( staticInstance == nil )
	{
		staticInstance = [GLK2TextureTracker new];
	}
	
	return staticInstance;
}

+(void) forceDeallocSharedInstance
{
	NSLog(@"This should ONLY be used when testing - it is not intended as part of the public API");
	
	if( staticInstance != nil )
	{
		staticInstance->isDeallocing = TRUE; // suprresses all further tracking, so textures can dealloc as NOP
		[staticInstance release];
		staticInstance = nil;
	}
}

-(void)dealloc
{
	NSLog(@"[%@] Deallocing ... shouldn't be used in real apps, but dropping all textures", [self class] );
	
	NSArray* keysClone = [[self.thingsReferringToGPUTextures copy] autorelease];
	for( NSNumber* n in keysClone )
	{
		GLuint textureName = [n unsignedIntValue];
		[[self.thingsReferringToGPUTextures objectForKey:n] removeAllObjects];
		[self internalProcessZeroReferencesLeftForGPUTexture:textureName];
	}
	self.thingsReferringToGPUTextures = nil;
	self.glContextsForEachGPUTexture = nil;
	
	[super dealloc];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
		self.thingsReferringToGPUTextures = [NSMutableDictionary dictionary];
		self.glContextsForEachGPUTexture = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void) internalIncrementReferenceFor:(GLuint) textureName withReferrer:(id) referrer
{
	if( isDeallocing )
		return;
	
	NSMutableArray* list = [self.thingsReferringToGPUTextures objectForKey:@(textureName)];
	if( list == nil )
	{
		list = [NSMutableArray array]; // FIXME: replace this with the Apple alternative array that does NOT retain its elements
		[self.thingsReferringToGPUTextures setObject:list forKey:@(textureName)];
	}
	
	[list addObject:referrer];
	[referrer autorelease]; // we MUST have a weak reference here, or else textures will never dealloc!
}

-(void) internalDecrementReferenceFor:(GLuint) textureName withReferrer:(id) referrer
{
	if( isDeallocing )
		return;
	
	NSMutableArray* list = [self.thingsReferringToGPUTextures objectForKey:@(textureName)];
	NSAssert( list != nil, @"Serious internal error: tried to decrement a reference to a GL texture name that already had zero references" );
	
	NSUInteger index = [list indexOfObject:referrer]; // WARNING: Apple's "removeObject:" is broken; removes ALL objects, not just one!
	NSAssert( index != NSNotFound, @"Tried to remove a referrer's reference to GL name (%i), but we had no record of that referrer = %@", textureName, referrer );
	
	[[list objectAtIndex:index] retain]; // Required since Apple will release in the next line :(
	[list removeObjectAtIndex:index];
	
	if( list.count < 1 )
	{
		[self internalProcessZeroReferencesLeftForGPUTexture:textureName];
	}
}

-(void)gpuTextureCreatedWithoutClassTexture:(GLuint)textureName
{
	if( isDeallocing )
		return;
	
	NSAssert( ![self.thingsReferringToGPUTextures.allKeys containsObject:@(textureName)], @"Shouldn't be possible to create a gpu texture that we believed already existed; must be a bug somewhere in this class - or there is something in your app that's creating glGenTextures without informing this class (i.e. a bug in your app). TextureName = %i", textureName );
	
	NSAssert([EAGLContext currentContext] != nil, @"Illegal with Apple driver to create a texture with no EAGLContext");
	
	[self.glContextsForEachGPUTexture setObject:[EAGLContext currentContext] forKey:@(textureName)];
	
	[self internalIncrementReferenceFor:textureName withReferrer:[kUNKNOWN_SOURCE_NORMAL retain]]; // the referrer will NOT be retained internally
}

-(void) gpuTextureArtificiallyRetain:(GLuint)textureName retainer:(NSObject*) retainer
{
	if( isDeallocing )
		return;
	
	[self internalIncrementReferenceFor:textureName withReferrer:[retainer retain]];
}
-(void) gpuTextureStopArtificiallyRetaining:(GLuint)textureName retainer:(NSObject*) retainer
{
	if( isDeallocing )
		return;
	
	[self internalDecrementReferenceFor:textureName withReferrer:[retainer retain]];
}

-(void)gpuTextureReleasedWithoutClassTexture:(GLuint)textureName
{
	if( isDeallocing )
		return;
	
	[self internalDecrementReferenceFor:textureName withReferrer:[kUNKNOWN_SOURCE_NORMAL retain]]; // the referrer will NOT be retained internally
}

-(void)classTextureCreated:(GLK2Texture *)texture
{
	if( isDeallocing )
		return;
	
	if( [self.glContextsForEachGPUTexture objectForKey:@(texture.glName)] == nil )
	{
		/** First time this texture has been created, must store the EAGLContext to fix APPLE severe bug */
		
		NSAssert([EAGLContext currentContext] != nil, @"Illegal with Apple driver to create a texture with no EAGLContext");
		
		[self.glContextsForEachGPUTexture setObject:[EAGLContext currentContext] forKey:@(texture.glName)];
	}
	
	[self internalIncrementReferenceFor:texture.glName withReferrer:texture];
}

-(void)classTexture:(GLK2Texture*) texture switchingFrom:(GLuint)oldTextureName toNew:(GLuint)newTextureName
{
	if( isDeallocing )
		return;
	
	[self internalIncrementReferenceFor:newTextureName withReferrer:texture];
	[self internalDecrementReferenceFor:oldTextureName withReferrer:texture];
}

-(void)classTextureDeallocing:(GLK2Texture *)texture
{
	if( isDeallocing )
		return;
	
	[self internalDecrementReferenceFor:texture.glName withReferrer:texture];
}

-(void) internalDestroyTextureNamed:(NSNumber*) textureNameNumber
{
	NSMutableArray* list = [self.thingsReferringToGPUTextures objectForKey:textureNameNumber];
	
	NSAssert( list.count < 1, @"You should not destory textures that are still in use" );
	
	NSLog(@"internalDestroyTextureNamed:%@ -- found glTexture with no references, deleting from GPU...", textureNameNumber );
	
	EAGLContext* texturesOriginalContext = [self.glContextsForEachGPUTexture objectForKey:textureNameNumber];
	if( [EAGLContext currentContext] != texturesOriginalContext )
		[EAGLContext setCurrentContext:texturesOriginalContext];
	
	GLuint textureName = [textureNameNumber unsignedIntValue];
	glDeleteTextures(1, &textureName);

}

-(NSUInteger) garbageCollectDanglingGPUTextures
{
	EAGLContext* globalContextAtStart = [EAGLContext currentContext];
	
	NSMutableArray* keysToRemove = [NSMutableArray array];
	for( NSNumber* key in self.thingsReferringToGPUTextures )
	{
		if( [[self.thingsReferringToGPUTextures objectForKey:key] count] < 1 )
		{
			[self internalDestroyTextureNamed:key];
			[keysToRemove addObject:key];
		}
	}
	
	for( id key in keysToRemove )
	{
		[self.thingsReferringToGPUTextures removeObjectForKey:key];
	}
	
	if( globalContextAtStart != [EAGLContext currentContext])
		[EAGLContext setCurrentContext:globalContextAtStart];
	return keysToRemove.count;
}

#pragma mark - Internal methods to auto-delete GPU textures

-(void) internalProcessZeroReferencesLeftForGPUTexture:(GLuint) textureName
{
	switch( self.cleanupMode )
	{
		case GLK2TextureTrackerCleanupModeInstant:
		{
			[self internalDestroyTextureNamed:@(textureName)];
			[self.thingsReferringToGPUTextures removeObjectForKey:@(textureName)];
		}break;
			
		case GLK2TextureTrackerCleanupModePeriodic:
		{
			NSLog(@"Texture name = %i now has zero references, will be deleted from GPU next time you call garbageCollectDanglingGPUTextures", textureName );
		}break;
	}
}

#pragma mark - Useful diagnostics and output info

-(NSUInteger)totalGLTexturesCurrentlyOnGPU
{
	return [self.thingsReferringToGPUTextures count];
}

-(NSArray*) textureNamesOnGPU
{
	return self.thingsReferringToGPUTextures.allKeys;
}

-(NSArray*) referencesToTexture:(GLuint) textureName
{
	return [self.thingsReferringToGPUTextures objectForKey:@(textureName)];
}

-(NSString *)description
{
	NSMutableString* s = [NSMutableString string];
	
	[s appendString:@"<TextureTracker:"];
	[s appendFormat:@" GL Textures on GPU: %llu", (unsigned long long)self.thingsReferringToGPUTextures.count];
//	[s appendFormat:@", "];
	[s appendString:@">"];
	
	return s;
}

@end

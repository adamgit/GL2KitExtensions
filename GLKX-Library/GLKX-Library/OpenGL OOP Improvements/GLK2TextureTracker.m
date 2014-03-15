#import "GLK2TextureTracker.h"

#import "GLK2TextureTracker_UnitTesting.h" // private methods for unit testing

@interface GLK2TextureTracker ()
@property(nonatomic,retain) NSMutableDictionary* thingsReferringToGPUTextures;
@end

@implementation GLK2TextureTracker


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
		[staticInstance release];
		staticInstance = nil;
	}
}

-(void)dealloc
{
	NSLog(@"[%@] Deallocing ... shouldn't be used in real apps, but dropping all textures", [self class] );
	
	for( NSNumber* n in self.thingsReferringToGPUTextures )
	{
		GLuint textureName = [n unsignedIntValue];
		[self internalProcessZeroReferencesLeftForGPUTexture:textureName];
	}
	self.thingsReferringToGPUTextures = nil;
	
	[super dealloc];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
		self.thingsReferringToGPUTextures = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void) internalIncrementReferenceFor:(GLuint) textureName withReferrer:(id) referrer
{
	NSMutableArray* list = [self.thingsReferringToGPUTextures objectForKey:@(textureName)];
	if( list == nil )
	{
		list = [NSMutableArray array];
		[self.thingsReferringToGPUTextures setObject:list forKey:@(textureName)];
	}
	
	[list addObject:referrer];
	[referrer autorelease]; // we MUST have a weak reference here, or else textures will never dealloc!
}

-(void) internalDecrementReferenceFor:(GLuint) textureName withReferrer:(id) referrer
{
	NSMutableArray* list = [self.thingsReferringToGPUTextures objectForKey:@(textureName)];
	NSAssert( list != nil, @"Serious internal error: tried to decrement a reference to a GL texture name that already had zero references" );
	
	NSUInteger index = [list indexOfObject:referrer]; // WARNING: Apple's "removeObject:" is broken; removes ALL objects, not just one!
	NSAssert( index != NSNotFound, @"Tried to remove a referrer's reference to GL name (%i), but we had no record of that referrer = %@", textureName, referrer );
	
	[list removeObjectAtIndex:index];
	
	if( list.count < 1 )
	{
		[self internalProcessZeroReferencesLeftForGPUTexture:textureName];
		[self.thingsReferringToGPUTextures removeObjectForKey:@(textureName)];
	}
}

-(void)gpuTextureCreatedWithoutClassTexture:(GLuint)textureName
{
	NSAssert( ![self.thingsReferringToGPUTextures.allKeys containsObject:@(textureName)], @"Shouldn't be possible to create a gpu texture that we believed already existed; must be a bug somewhere in this class - or there is something in your app that's creating glGenTextures without informing this class (i.e. a bug in your app). TextureName = %i", textureName );
	
	[self internalIncrementReferenceFor:textureName withReferrer:[@"unknown source" retain]]; // the referrer will NOT be retained internally
}

-(void)gpuTextureReleasedWithoutClassTexture:(GLuint)textureName
{
	[self internalDecrementReferenceFor:textureName withReferrer:[@"unknown source" retain]]; // the referrer will NOT be retained internally
}

-(void)classTextureCreated:(GLK2Texture *)texture
{
	[self internalIncrementReferenceFor:texture.glName withReferrer:texture];
}

-(void)classTextureDeallocing:(GLK2Texture *)texture
{
	[self internalDecrementReferenceFor:texture.glName withReferrer:texture];
}

#pragma mark - Internal methods to auto-delete GPU textures

-(void) internalProcessZeroReferencesLeftForGPUTexture:(GLuint) textureName
{
	NSLog(@"Texture name = %i now has zero references, considering whether to glDeleteTextures on it", textureName );
	
	glDeleteTextures(1, &textureName);
}

#pragma mark - Useful diagnostics and output info

-(NSUInteger)totalGLTexturesCurrentlyOnGPU
{
	return [self.thingsReferringToGPUTextures count];
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

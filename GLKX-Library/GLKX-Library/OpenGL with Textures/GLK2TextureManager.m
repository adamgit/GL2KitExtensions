
#import "GLK2TextureManager.h"

@interface GLK2TextureManager()
@property(nonatomic,retain) NSMutableSet* allGLK2TexturesWeaklyRetained;
@property(nonatomic,retain) NSMutableSet* allGPUTextureNamesWithoutGLK2Textures;
@end

@implementation GLK2TextureManager

/**
 Internally, we use a singleton, simply because Objective-C isn't very good
 with class-level methods - some of the core standard-library functions aren't
 implemented for use in static context - so it makes life easier to convert to
 instance methods internally.
 
 I don't like this - but until Apple rewrites their libraries, or the language,
 it's best not to fight it.
 */
static GLK2TextureManager* staticInstance;
+(GLK2TextureManager*) sharedInstance
{
	if( staticInstance == nil )
	{
		staticInstance = [GLK2TextureManager new];
	}
	
	return staticInstance;
}

+(void)didCreateTextureWithName:(GLuint)textureName
{
	[[self sharedInstance] didCreateTextureWithName:textureName];
}
+(void)didCreateTexture:(GLK2Texture *)texture
{
	[[self sharedInstance] didCreateTexture:texture];
}

+(void)willDestroyTextureWithName:(GLuint)textureName
{
	[[self sharedInstance] willDestroyTextureWithName:textureName];
}
+(void)willDestroyTexture:(GLK2Texture *)texture
{
	[[self sharedInstance] willDestroyTexture:texture];
}

+(NSObject<NSCopying,NSSecureCoding,NSFastEnumeration> *)allKnownGLK2Textures
{
	return [[self sharedInstance] allKnownGLK2Textures];
}
+(NSObject<NSCopying,NSSecureCoding,NSFastEnumeration> *)allKnownTextureNames
{
	return [[self sharedInstance] allKnownTextureNames];
}

+(NSString *)debugInstanceDescription
{
	return [[self sharedInstance] description];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.allGLK2TexturesWeaklyRetained = [NSMutableSet set];
		self.allGPUTextureNamesWithoutGLK2Textures = [NSMutableSet set];
    }
    return self;
}

-(void)dealloc
{
	NSAssert(FALSE, @"This class should never dealloc; it's designed to allocate once only, and never die. Will need careful examination to be sure it works OK if dealloc'd - NB: dealloc'ing might break assumptions made by other classes!");
	
	[super dealloc];
}

-(void)didCreateTextureWithName:(GLuint)textureName
{
	[self.allGPUTextureNamesWithoutGLK2Textures addObject:@(textureName)];
}
-(void)didCreateTexture:(GLK2Texture *)texture
{
	if( [self.allGLK2TexturesWeaklyRetained containsObject:texture])
		;
	else
	{
		[self.allGLK2TexturesWeaklyRetained addObject:[texture autorelease]]; // counteract the Set's own retain
	}
}

-(void)willDestroyTextureWithName:(GLuint)textureName
{
	[self.allGPUTextureNamesWithoutGLK2Textures removeObject:@(textureName)];
}
-(void)willDestroyTexture:(GLK2Texture *)texture
{
	if( [self.allGLK2TexturesWeaklyRetained containsObject:texture])
	{
		[texture retain]; // to counteract the unwanted release Apple is about to do
		[self.allGLK2TexturesWeaklyRetained removeObject:texture];
	}
}


-(NSObject<NSCopying,NSSecureCoding,NSFastEnumeration> *)allKnownGLK2Textures
{
	return [self.allGLK2TexturesWeaklyRetained allObjects];
}
-(NSObject<NSCopying,NSSecureCoding,NSFastEnumeration> *)allKnownTextureNames
{
	NSMutableArray* a = [NSMutableArray arrayWithArray:[self.allGLK2TexturesWeaklyRetained allObjects]];
	[a addObjectsFromArray:[self.allGPUTextureNamesWithoutGLK2Textures allObjects]];
	
	return a;
}

-(NSString *)description
{
	NSMutableString* result = [NSMutableString string];
	[result appendString:@"GLK2TextureManager {"];
	for( GLK2Texture* t in self.allGLK2TexturesWeaklyRetained )
	{
		//FIXME: I would like to "catch" in case you foolishly release a texture without informing me ...
		// ... but I don't know a way to do that with ObjC. Instead, if that happens, you'll get a runtime crash.
		[result appendFormat:@"Texture:%i,", t.glName ];
	}
	
	for( NSNumber* n in self.allGPUTextureNamesWithoutGLK2Textures )
	{
		[result appendFormat:@"TextureNamed:%i,", [n intValue] ];
	}
	
	return result;
}

@end

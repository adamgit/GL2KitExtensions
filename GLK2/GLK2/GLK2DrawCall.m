#import "GLK2DrawCall.h"

@implementation GLK2DrawCall
{
	float clearColour[4];
}

-(void)dealloc
{
	self.texturesFromSamplers = nil;
	
	[super dealloc];
}

- (id)init
{
	self = [super init];
	if (self) {
		[self setClearColourRed:1.0f green:0 blue:1.0f alpha:1.0f];
		self.texturesFromSamplers = [NSMutableDictionary dictionary];
	}
	return self;
}

#pragma mark - glClear

-(float*) clearColourArray
{
	return &clearColour[0];
}

-(void) setClearColourRed:(float) r green:(float) g blue:(float) b alpha:(float) a
{
	clearColour[0] = r;
	clearColour[1] = g;
	clearColour[2] = b;
	clearColour[3] = a;
}

#pragma mark - textures

-(void)setTexture:(GLK2Texture *)texture forSampler:(GLK2Uniform *)sampler
{
	if( texture != nil )
		[self.texturesFromSamplers setObject:texture forKey:sampler];
	else
		[self.texturesFromSamplers removeObjectForKey:sampler];
}

@end

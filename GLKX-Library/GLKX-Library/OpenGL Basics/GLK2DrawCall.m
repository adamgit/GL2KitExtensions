#import "GLK2DrawCall.h"

@interface GLK2DrawCall()
@property(nonatomic,retain) NSMutableArray* textureUnitSlots;
@end

@implementation GLK2DrawCall
{
	float clearColour[4];
}

-(void)dealloc
{
	self.texturesFromSamplers = nil;
	self.textureUnitSlots = nil;
	self.shaderProgram = nil;
	self.VAO = nil;
	
	NSLog(@"Drawcall dealloced: %@", [self class] );
	
	[super dealloc];
}

- (id)init
{
	self = [super init];
	if (self) {
		[self setClearColourRed:1.0f green:0 blue:1.0f alpha:1.0f];
		self.requiresDepthTest = TRUE;
		
		self.texturesFromSamplers = [NSMutableDictionary dictionary];
		
		GLint sizeOfTextureUnitSlotsArray; // MUST be fixed size, and have an entry for every index!
		glGetIntegerv( GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS, &sizeOfTextureUnitSlotsArray );
		self.textureUnitSlots = [NSMutableArray arrayWithCapacity:sizeOfTextureUnitSlotsArray];
		for( int i=0; i<sizeOfTextureUnitSlotsArray; i++ )
			[self.textureUnitSlots addObject:[NSNull null]]; // marks this slto as "currently empty"
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

@end

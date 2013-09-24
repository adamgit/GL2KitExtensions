#import "GLK2DrawCall.h"

@implementation GLK2DrawCall
{
	float clearColour[4];
}

-(void)dealloc
{
	[super dealloc];
}

- (id)init
{
	self = [super init];
	if (self) {
		[self setClearColourRed:1.0f green:0 blue:1.0f alpha:1.0f];
	}
	return self;
}

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

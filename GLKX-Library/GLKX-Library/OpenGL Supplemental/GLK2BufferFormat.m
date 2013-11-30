#import "GLK2BufferFormat.h"

@interface GLK2BufferFormat()
@property(nonatomic,retain) NSArray* numFloatsPerItem, *bytesPerItem;
@end

@implementation GLK2BufferFormat

+(GLK2BufferFormat *)bufferFormatWithSingleTypeOfFloats:(GLuint)numFloats bytesPerItem:(GLsizeiptr)bytesPerItem
{
	GLK2BufferFormat* newValue = [[GLK2BufferFormat new] autorelease];
	
	newValue.numberOfSubTypes = 1;
	newValue.numFloatsPerItem = @[ @(numFloats) ];
	newValue.bytesPerItem = @[ @(bytesPerItem) ];
	
	return newValue;
}

+(GLK2BufferFormat *)bufferFormatWithFloatsPerItem:(NSArray*) floatsArray bytesPerItem:(NSArray*) bytesArray
{
	GLK2BufferFormat* newValue = [[GLK2BufferFormat new] autorelease];
	
	newValue.numberOfSubTypes = 1;
	newValue.numFloatsPerItem = floatsArray;
	newValue.bytesPerItem = bytesArray;
	
	return newValue;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.numFloatsPerItem = [NSMutableArray array];
		self.bytesPerItem = [NSMutableArray array];
    }
    return self;
}

-(GLuint)sizePerItemInFloatsForSubTypeIndex:(int)index
{
	/** Apple currently defines GLuint as "unsigned int" */
	return [((NSNumber*)[self.numFloatsPerItem objectAtIndex:index]) unsignedIntValue];
}

-(GLsizeiptr)bytesPerItemForSubTypeIndex:(int)index
{
	/** Apple currently defines GLsizeiptr as "long" */
	return [((NSNumber*)[self.bytesPerItem objectAtIndex:index]) longValue];
}

@end

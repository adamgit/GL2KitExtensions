#import "GLK2BufferObject.h"

@interface GLK2BufferObject()
@property(nonatomic, readwrite) GLuint glName;
@property(nonatomic, readwrite) GLsizeiptr totalBytesPerItem;
@end

@implementation GLK2BufferObject

+(GLK2BufferObject *)vertexBufferObject
{
	GLK2BufferObject* newObject = [[GLK2BufferObject new] autorelease];
	newObject.glBufferType = GL_ARRAY_BUFFER;
	
	return newObject;
}

- (id)init
{
    self = [super init];
    if (self) {
        glGenBuffers(1, &_glName);
    }
    return self;
}

- (void)dealloc
{
	if( self.glName > 0 )
	{
		NSLog(@"[%@] glDeleteBuffer(%i)", [self class], self.glName);
		glDeleteBuffers(1, &_glName);
	}
	
	[super dealloc];
}

-(void) bind
{
	glBindBuffer(GL_ARRAY_BUFFER, self.glName);
}

-(GLenum) getUsageEnumValueFromFrequency:(GLK2BufferObjectFrequency) frequency nature:(GLK2BufferObjectNature) nature
{
	GLenum usage;
	
	switch( frequency )
	{
		case GLK2BufferObjectFrequencyDynamic:
		{
			switch( nature )
			{
				case GLK2BufferObjectNatureCopy:
				case GLK2BufferObjectNatureRead:
					NSAssert(FALSE, @"Illegal in GL ES 2");
					usage = 0;
					break;
				case GLK2BufferObjectNatureDraw:
					usage = GL_DYNAMIC_DRAW;
					break;
					
				default:
					NSAssert(FALSE, @"Illegal parameters");
			}
		}break;
			
		case GLK2BufferObjectFrequencyStatic:
		{
			switch( nature )
			{
				case GLK2BufferObjectNatureCopy:
				case GLK2BufferObjectNatureRead:
					NSAssert(FALSE, @"Illegal in GL ES 2");
					usage = 0;
					break;
				case GLK2BufferObjectNatureDraw:
					usage = GL_STATIC_DRAW;
					break;
					
				default:
					NSAssert(FALSE, @"Illegal parameters");
			}
		}break;
			
		case GLK2BufferObjectFrequencyStream:
		{
			switch( nature )
			{
				case GLK2BufferObjectNatureCopy:
				case GLK2BufferObjectNatureRead:
					NSAssert(FALSE, @"Illegal in GL ES 2");
					usage = 0;
					break;
				case GLK2BufferObjectNatureDraw:
					usage = GL_STREAM_DRAW;
					break;
					
				default:
					NSAssert(FALSE, @"Illegal parameters");
			}
		}break;
			
		default:
			NSAssert(FALSE, @"Illegal parameters");
	}
	return usage;
}

-(void)setCurrentFormat:(GLK2BufferFormat *)newValue
{
	[_currentFormat release];
	_currentFormat = newValue;
	[_currentFormat retain];
	
	self.totalBytesPerItem = 0;
	for( int i=0; i<self.currentFormat.numberOfSubTypes; i++ )
	{
		GLsizeiptr bytesPerItem = [self.currentFormat bytesPerItemForSubTypeIndex:i];
		
		NSAssert( bytesPerItem > 0 , @"Invalid GLK2BufferFormat");
		
		self.totalBytesPerItem += bytesPerItem;
	}
}

-(void) upload:(void *) dataArray numItems:(int) count usageHint:(GLenum) usage withNewFormat:(GLK2BufferFormat*) bFormat
{
	self.currentFormat = bFormat;
	[self upload:dataArray numItems:count usageHint:usage];
}

-(void) upload:(void *) dataArray numItems:(int) count usageHint:(GLenum) usage
{
	NSAssert( self.currentFormat != nil, @"Use the version of this method that takes a new GLK2BufferFormat, or set self.contentsFormat manually");
	
	glBindBuffer( self.glBufferType, self.glName );
	
	glBufferData( GL_ARRAY_BUFFER, count * self.totalBytesPerItem, dataArray, usage);
}

@end

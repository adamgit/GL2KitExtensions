#import "GLK2VertexArrayObject.h"

#import <GLKit/GLKit.h>

@interface GLK2VertexArrayObject()
@property(nonatomic, readwrite) GLuint glName;
@end

@implementation GLK2VertexArrayObject

- (id)init
{
    self = [super init];
    if (self) {
        glGenVertexArraysOES( 1, &_glName );
		self.VBOs = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc
{
	self.VBOs = nil;
	if( self.glName > 0 )
	{
		NSLog(@"[%@] glDeleteVertexArraysOES(%i)", [self class], self.glName);
		glDeleteVertexArraysOES( 1, &_glName);
	}
	
    [super dealloc];
}

-(GLK2BufferObject*) addVBOForAttribute:(GLK2Attribute*) targetAttribute filledWithData:(void*) data bytesPerArrayElement:(GLsizeiptr) bytesPerDataItem  arrayLength:(int) numDataItems
{
	return [self addVBOForAttribute:targetAttribute filledWithData:data bytesPerArrayElement:bytesPerDataItem arrayLength:numDataItems updateFrequency:GLK2BufferObjectFrequencyStatic];
}

-(GLK2BufferObject*) addVBOForAttribute:(GLK2Attribute*) targetAttribute filledWithData:(void*) data bytesPerArrayElement:(GLsizeiptr) bytesPerDataItem arrayLength:(int) numDataItems updateFrequency:(GLK2BufferObjectFrequency) freq
{
	NSAssert(targetAttribute != nil, @"Can't add a VBO for a nil vertex-attribute");
	
	
	return [self addVBOForAttributes:@[targetAttribute] filledWithData:data inFormat:[GLK2BufferFormat bufferFormatWithSingleTypeOfFloats:bytesPerDataItem/4 bytesPerItem:bytesPerDataItem] numVertices:numDataItems updateFrequency:freq];
}

-(GLK2BufferObject*) addVBOForAttributes:(NSArray*) targetAttributes filledWithData:(void*) data inFormat:(GLK2BufferFormat*) bFormat numVertices:(int) numDataItems updateFrequency:(GLK2BufferObjectFrequency) freq
{		
	/** Create a VBO on the GPU, to store data */
	GLK2BufferObject* newVBO = [GLK2BufferObject vertexBufferObject];
	[self.VBOs addObject:newVBO]; // so we can auto-release it when this class deallocs
	
	/** Send the vertex data to the new VBO */
	[newVBO upload:data numItems:numDataItems usageHint:[newVBO getUsageEnumValueFromFrequency:freq nature:GLK2BufferObjectNatureDraw] withNewFormat:bFormat];
	
	/** Configure the VAO (state) */
	glBindVertexArrayOES( self.glName );
	GLsizeiptr bytesForPreviousItems = 0;
	int i = -1;
	for( GLK2Attribute* targetAttribute in targetAttributes )
	{
		i++;
		GLuint numFloatsForItem = [newVBO.currentFormat sizePerItemInFloatsForSubTypeIndex:i];
		GLsizeiptr bytesPerItem = [newVBO.currentFormat bytesPerItemForSubTypeIndex:i];
				
		glEnableVertexAttribArray( targetAttribute.glLocation );
		glVertexAttribPointer( targetAttribute.glLocation, numFloatsForItem, GL_FLOAT, GL_FALSE, newVBO.totalBytesPerItem, (const GLvoid*) bytesForPreviousItems);
		bytesForPreviousItems += bytesPerItem;
	}
	glBindVertexArrayOES(0); //unbind the vertex array, as a precaution against accidental changes by other classes
	
	return newVBO;
}

@end

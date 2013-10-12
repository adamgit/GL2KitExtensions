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
	/** Create a VBO on the GPU, to store data */
	GLK2BufferObject* newVBO = [GLK2BufferObject vertexBufferObject];
	newVBO.bytesPerItem = bytesPerDataItem;
	[self.VBOs addObject:newVBO]; // so we can auto-release it when this class deallocs
	
	/** Send the vertex data to the new VBO */
	[newVBO upload:data numItems:numDataItems usageHint:[newVBO getUsageEnumValueFromFrequency:freq nature:GLK2BufferObjectNatureDraw]];
	
	/** Configure the VAO (state) */
	glBindVertexArrayOES( self.glName );

	glEnableVertexAttribArray( targetAttribute.glLocation );
	GLsizei stride = 0;
	glVertexAttribPointer( targetAttribute.glLocation, newVBO.sizePerItemInFloats, GL_FLOAT, GL_FALSE, stride, 0);
	
	glBindVertexArrayOES(0); //unbind the vertex array, as a precaution against accidental changes by other classes
	
	return newVBO;
}

@end

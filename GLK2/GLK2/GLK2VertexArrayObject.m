#import "GLK2VertexArrayObject.h"

#import <GLKit/GLKit.h>

@interface GLK2VertexArrayObject()
@property(nonatomic, readwrite) GLuint glName;
@property(nonatomic, retain) NSMutableDictionary* attributeArraysByVBOName;
@end

@implementation GLK2VertexArrayObject

- (id)init
{
    self = [super init];
    if (self) {
        glGenVertexArraysOES( 1, &_glName );
		self.VBOs = [NSMutableArray array];
		self.attributeArraysByVBOName = [NSMutableDictionary dictionary]; // so we can find the VBO containing a set of attributes later
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

-(GLK2BufferObject*) addVBOForAttribute:(GLK2Attribute*) targetAttribute filledWithData:(const void*) data bytesPerArrayElement:(GLsizeiptr) bytesPerDataItem  arrayLength:(int) numDataItems
{
	return [self addVBOForAttribute:targetAttribute filledWithData:data bytesPerArrayElement:bytesPerDataItem arrayLength:numDataItems updateFrequency:GLK2BufferObjectFrequencyStatic];
}

-(GLK2BufferObject*) addVBOForAttribute:(GLK2Attribute*) targetAttribute filledWithData:(const void*) data bytesPerArrayElement:(GLsizeiptr) bytesPerDataItem arrayLength:(int) numDataItems updateFrequency:(GLK2BufferObjectFrequency) freq
{
	NSAssert(targetAttribute != nil, @"Can't add a VBO for a nil vertex-attribute");
	
	
	return [self addVBOForAttributes:@[targetAttribute] filledWithData:data inFormat:[GLK2BufferFormat bufferFormatWithSingleTypeOfFloats:bytesPerDataItem/4 bytesPerItem:bytesPerDataItem] numVertices:numDataItems updateFrequency:freq];
}

-(GLK2BufferObject*) addVBOForAttributes:(NSArray*) targetAttributes filledWithData:(const void*) data inFormat:(GLK2BufferFormat*) bFormat numVertices:(int) numDataItems updateFrequency:(GLK2BufferObjectFrequency) freq
{
	/** Create a VBO on the GPU, to store data */
	GLK2BufferObject* newVBO = [GLK2BufferObject vertexBufferObject];
	[self.VBOs addObject:newVBO]; // so we can auto-release it when this class deallocs
	[self.attributeArraysByVBOName setObject:targetAttributes forKey:@(newVBO.glName)];
	NSLog(@"VAO[%i] now has %i VBOs", self.glName, [self.VBOs count]);
	
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

-(GLK2BufferObject*) VBOContainingOrderedAttributes:(NSArray*) targetAttributes
{
	GLuint matchedBufferName = 0;
	for( NSNumber* numberOfName in self.attributeArraysByVBOName )
	{
		NSArray* attsForNumber = [self.attributeArraysByVBOName objectForKey:numberOfName];
		
		if( [targetAttributes isEqualToArray:attsForNumber] ) // only works because we implemented isEqual: on GLK2Attribute
		{
			matchedBufferName = (GLuint) [numberOfName unsignedIntValue];
			break;
		}
	}
	if( matchedBufferName != 0 )
	{
		for(  GLK2BufferObject* bo in self.VBOs )
		{
			if( bo.glName == matchedBufferName )
				return bo;
		}
		
		NSAssert(FALSE, @"Major error: we found a buffer name (%i) that should have matched to one of our buffers in: %@", matchedBufferName, self.VBOs );
		return nil;
	}
	else
		return nil;
}

-(void) detachVBO:(GLK2BufferObject*) bufferToDetach
{
	int index = [self.VBOs indexOfObject:bufferToDetach];
	
	NSAssert( index > -1, @"Couldn't find that VBO to detach!" );
	
	/** Major problem with Xcode5: even without ARC, Apple is incorrectly release'ing a reference too early here, the moment something leaves the array, instead of "at end of main loop" */
	[bufferToDetach retain];
	
	[self.VBOs removeObjectAtIndex:index];
	[self.attributeArraysByVBOName removeObjectForKey:@(bufferToDetach.glName)];
	
	NSLog(@"VAO[%i]: released VBO with name = %i; if I was last remaining VAO, ObjC should dealloc it, and OpenGL will then delete it", self.glName, bufferToDetach.glName );
	[bufferToDetach release];
}

@end

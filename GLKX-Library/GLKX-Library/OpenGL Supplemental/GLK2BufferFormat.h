/**
 This does not directly map to anything in OpenGL, but when you put interleaved data into a
 VertexBufferObject, OpenGL *requires* you to track the format of that interleaved data, and
 supply it back to OpenGL later.
 
 This class holds that data
 */
#import <Foundation/Foundation.h>

@interface GLK2BufferFormat : NSObject

+(GLK2BufferFormat*) bufferFormatWithSingleTypeOfFloats:(GLuint) numFloats bytesPerItem:(GLsizeiptr) bytesPerItem;

@property(nonatomic) int numberOfSubTypes;

/**
 The VertexArrayObject methods are fundamentally incompatible, and use "floats" as the unit-of-size, instead of "bytes",
 so you need to know the number of floats-per-item-in-the-buffer, when it comes time to call glVertexAttribPointer
 */
-(GLuint) sizePerItemInFloatsForSubTypeIndex:(int) index;

/** Buffers can contain any freeform data; however, to use a Buffer, OpenGL requires you to track the format of the
 contents, and tell it how many "bytes" each element in the buffer uses.
 
 e.g. for a GLKVector3, you have 3 floats, and each float is a 32bit number, i.e. 4 bytes. So, a GLKVector3 has
 a bytesPerItem = 3 * 4 = 12.
 
 Usually, you use C's sizeof property to auto-calculate this for you correctly.
 */
-(GLsizeiptr) bytesPerItemForSubTypeIndex:(int) index;

@end

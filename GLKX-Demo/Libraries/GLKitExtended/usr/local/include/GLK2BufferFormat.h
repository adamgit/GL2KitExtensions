/**
 This does not directly map to anything in OpenGL, but when you put interleaved data into a
 VertexBufferObject, OpenGL *requires* you to track the format of that interleaved data, and
 supply it back to OpenGL later.
 
 This class holds that data
 */
#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface GLK2BufferFormat : NSObject

/**
 It would be much cleaner to accept e.g. "GLKVector3" as argument, but Apple chose to implement
 their OpenGL code in C, and C is a weak language, which has no introspection for struct types.
 
 i.e. there is no way for us to detect the difference between a GLKVector2 and a GLKVector3 etc.
 
 So, instead, we ask for the number of GL_FLOAT's.
 
 NB: this method is the "most commonly used simple VBO (1 x attribute containing a single GLKit
 struct - e.g. GLKVector3 or GLKMatrix4)" ... which explains the lack of detailed options.
 */
+(GLK2BufferFormat *)bufferFormatOneAttributeMadeOfGLFloats:(GLuint)numFloats;

/**
 Fully configurable instantiator: this lets you specify multiple attributes in a single
 VBO, with any number of floats each, and any number of bytes per attribute (maybe you're using
 32bit floats, maybe you're using 16bit, maybe you're using 64bit, etc)
 */
+(GLK2BufferFormat *)bufferFormatWithFloatsPerItem:(NSArray*) floatsArray bytesPerItem:(NSArray*) bytesArray;

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

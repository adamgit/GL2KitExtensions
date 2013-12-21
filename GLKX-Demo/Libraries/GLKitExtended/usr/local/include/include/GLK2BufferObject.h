/**
 An OpenGL BufferObject - http://www.opengl.org/wiki/Buffer_Object
 
 Note that OpenGL requires you set the following for you to "use" a live buffer:
 
  - glBufferType (many GL methods need to be told which type, e.g. GL_ARRAY_BUFFER
  - bytesPerItem (required before uploading data to the GPU/bufferobject)
 
 */
#import <Foundation/Foundation.h>
#import "GLK2BufferFormat.h"

/** Half of the "usage" parameter as defined on http://www.opengl.org/sdk/docs/man/xhtml/glBufferData.xml */
typedef enum GLK2BufferObjectFrequency
{
	GLK2BufferObjectFrequencyStream,
	GLK2BufferObjectFrequencyStatic,
	GLK2BufferObjectFrequencyDynamic
} GLK2BufferObjectFrequency;

/** Half of the "usage" parameter as defined on http://www.opengl.org/sdk/docs/man/xhtml/glBufferData.xml */
typedef enum GLK2BufferObjectNature
{
	GLK2BufferObjectNatureDraw,
	GLK2BufferObjectNatureRead,
	GLK2BufferObjectNatureCopy
} GLK2BufferObjectNature;

@interface GLK2BufferObject : NSObject

/**
 Pre-Configures the buffertype to "GL_ARRAY_BUFFER", as required for VBO's
 
 The format argument is required (although you could provide "nil") because a VBO where you don't know
 the format is effectively junk data; it's very dangerous (in bugs / debugging terms) to allow yourself
 to create VBO's with no format
 */
+(GLK2BufferObject *)vertexBufferObjectWithFormat:(GLK2BufferFormat*) newFormat;

/**
 Uploads an empty buffer exactly large enough to hold the specified number of 'items', so that you can later fill it up
 using glBufferSubData. Even though glBufferSubData might be horribly slow, this method is needed in the cases
 where you have to store different data over time into the same buffer with the SAME attribute.
 
 If you are storing different data in different attributes, create new Buffers for each attribute - it's
 faster and much easier to implement
 */
+(GLK2BufferObject *)vertexBufferObjectWithFormat:(GLK2BufferFormat*) newFormat allocateCapacity:(NSUInteger) numItemsToPreAllocate;

/**
 Create a VBO and immediately upload some data to it - don't forget the format! You'll need this later in order to
 attach it to one or more VAO's */
+(GLK2BufferObject*) newVBOFilledWithData:(const void*) data inFormat:(GLK2BufferFormat*) bFormat numVertices:(int) numDataItems updateFrequency:(GLK2BufferObjectFrequency) freq;

/** OpenGL uses integers as "names" instead of Strings, because Strings in C are a pain to work with, and slower */
@property(nonatomic, readonly) GLuint glName;

/** A buffer can have any type; but as soon as you use it with a GL method, you have to specify the type. Generally, 
 you create a buffer for a specific purpose and only use it for that - unless you're low on memory and need to re-use.
 
 You are allowed to change this, while keeping the data the same - OpenGL is happy for you to treat the data as
 "typeless". However, it may reduce performance if you change the type to a different type while the app is running,
 since the GPU *may have* done optimization based on the type you 'first' used with this buffer.
 
 c.f. http://www.opengl.org/wiki/Buffer_Object
 
 The static methods - e.g. "vertexBufferObject" - set this automatically
 */
@property(nonatomic) GLenum glBufferType;

/** Buffers can contain any freeform data; however, to use a Buffer, OpenGL requires you to track the format of the
 contents, and tell it how many "bytes" each element in the buffer uses.
 
 e.g. for a GLKVector3, you have 3 floats, and each float is a 32bit number, i.e. 4 bytes. So, a GLKVector3 has
 a bytesPerItem = 3 * 4 = 12.
 
 Usually, you use C's sizeof property to auto-calcualte this for you correctly. I.e. if you've stored GLKVector3 objects
 in the buffer, call:
 
    (GLK2BufferObject).bytesPerItem = sizeof( GLKVector3 );
 
 */
@property(nonatomic,retain) GLK2BufferFormat* currentFormat;

/**
 Whenever you change the contentsFormat, this will be automatically updated
 */
@property(nonatomic,readonly) GLsizeiptr totalBytesPerItem;

/**
 OpenGL has two parameters which are combined into a single value and used as a "usage hint"; obviously, it would have
 been cleaner and saner to use TWO "usage hints", but we're stuck with it. This method does the combining correctly for
 you, and automatically detects the cases that are illegal in GL ES 2 (but may be legal in other GL versions)
 */
-(GLenum) getUsageEnumValueFromFrequency:(GLK2BufferObjectFrequency) frequency nature:(GLK2BufferObjectNature) nature;

/** Wraps glBufferData
 
 To automatically get the correct value for usageHint, use "getUsageEnumValueFromFrequency:nature:"
 */
-(void) upload:(const void *) dataArray numItems:(int) count usageHint:(GLenum) usage withNewFormat:(GLK2BufferFormat*) bFormat;

/**
 Uses the existing buffer format (self.contentsFormat) - will fail if that is not set
 */
-(void) upload:(const void *) dataArray numItems:(int) count usageHint:(GLenum) usage;

/** Wraps glBufferSubData -- NB this will ONLY work if you've already done a call to one of the "upload:" methods,
 OR if you created the buffer with a specific initial capacity; if not, the GPU won't have any memory allocated yet
 for you to upload into!

 */
-(void)uploadToOffset:(GLintptr)startOffset withData:(const void *)dataArray numItems:(int)count;

@end

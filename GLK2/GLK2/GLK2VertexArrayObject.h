#import <Foundation/Foundation.h>
#import "GLK2BufferObject.h"
#import "GLK2Attribute.h"

@interface GLK2VertexArrayObject : NSObject

@property(nonatomic, readonly) GLuint glName;

@property(nonatomic,retain) NSMutableArray* VBOs;

/** Delegates to the other method, defaults to using "GL_STATIC_DRAW" as the BufferObject update frequency */
-(GLK2BufferObject*) addVBOForAttribute:(GLK2Attribute*) targetAttribute filledWithData:(void*) data bytesPerArrayElement:(GLsizeiptr) bytesPerDataItem arrayLength:(int) numDataItems;

/** Fully configurable creation of VBO + upload of data into that VBO */
-(GLK2BufferObject*) addVBOForAttribute:(GLK2Attribute*) targetAttribute filledWithData:(void*) data bytesPerArrayElement:(GLsizeiptr) bytesPerDataItem arrayLength:(int) numDataItems updateFrequency:(GLK2BufferObjectFrequency) freq;

@end

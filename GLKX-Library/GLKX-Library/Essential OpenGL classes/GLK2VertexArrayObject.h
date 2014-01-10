#import <Foundation/Foundation.h>
#import "GLK2BufferObject.h"
#import "GLK2Attribute.h"

#define DEBUG_VAO_LIFECYCLE 0
#define DEBUG_VBO_HANDLING 0

@interface GLK2VertexArrayObject : NSObject

@property(nonatomic, readonly) GLuint glName;

@property(nonatomic,retain) NSMutableArray* VBOs;

/** Delegates to the other method, defaults to using "GL_STATIC_DRAW" as the BufferObject update frequency */
-(GLK2BufferObject*) addVBOForAttribute:(GLK2Attribute*) targetAttribute filledWithData:(const void*) data bytesPerArrayElement:(GLsizeiptr) bytesPerDataItem arrayLength:(int) numDataItems;

/** Fully configurable creation of VBO + upload of data into that VBO */
-(GLK2BufferObject*) addVBOForAttribute:(GLK2Attribute*) targetAttribute filledWithData:(const void*) data bytesPerArrayElement:(GLsizeiptr) bytesPerDataItem arrayLength:(int) numDataItems updateFrequency:(GLK2BufferObjectFrequency) freq;

/** If you have a VBO already uploaded to the GPU (e.g. used elsewhere), you can ADDITIONALLY add it to this VAO */
-(void) addVBO:(GLK2BufferObject*) vbo forAttributes:(NSArray*) targetAttributes numVertices:(int) numDataItems;

/**
 If you forget which VBO was which, you can use this to find the one that used the EXACT set of attributes (a single attribute, or an interleaved set) */
-(GLK2BufferObject*) VBOContainingOrderedAttributes:(NSArray*) targetAttributes;

/** Detaching DOES NOT AFFECT THE GPU; but it releases all of this VAO's references to that VBO on client-side,
 which should trigger a dealloc, which MAY trigger a deletion from the GPU (but only if its safe)
 */
-(void) detachVBO:(GLK2BufferObject*) bufferToDetach;

/** OpenGL's association of VAO's/VBO's has a very poor API, so you have to manually check and associate
 them whenever needed */
-(BOOL) containsVBO:(GLK2BufferObject*) buffer;
 
@end

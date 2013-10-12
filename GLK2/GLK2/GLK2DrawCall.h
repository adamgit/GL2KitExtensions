#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "GLK2ShaderProgram.h"
#import "GLK2VertexArrayObject.h"

/**
 Version 1: c.f. http://t-machine.org/index.php/2013/09/08/opengl-es-2-basic-drawing/
 Part 3: ... not published yet ...
 */
@interface GLK2DrawCall : NSObject

@property(nonatomic) BOOL shouldClearColorBit;

/** Every draw call MUST have a shaderprogram, or else it cannot draw objects nor pixels */
@property(nonatomic,retain) GLK2ShaderProgram* shaderProgram;

/** If this draw call has ANY geometry, it should go in a VBO (stores raw Vertex attributes),
 and the VBO should be embedded in a VAO (which stores the metadata about the geometry) */
@property(nonatomic,retain) GLK2VertexArrayObject* VAO;

/** Textures in GL ES 2 are different from old-style OpenGL, and you MUST track the named
 shader-uniform / shader-sampler2d variable that each texture is 'attached' to; because of
 the way OpenGL handles texture-memory, you can't "do this once and forget about it", you
 have to keep re-doing it frame to frame */
@property(nonatomic,retain) NSMutableDictionary* texturesFromSamplerNames;

/**
 Defaults to:
 
 - clear color MAGENTA
 
 ... everything else: OFF
 */
- (id)init;

-(float*) clearColourArray;
-(void) setClearColourRed:(float) r green:(float) g blue:(float) b alpha:(float) a;

@end

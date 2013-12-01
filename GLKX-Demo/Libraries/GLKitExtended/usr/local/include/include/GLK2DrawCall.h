#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "GLK2ShaderProgram.h"
#import "GLK2VertexArrayObject.h"
#import "GLK2Texture.h"
#import "GLK2UniformValueGenerator.h"

/**
 Version 1: c.f. http://t-machine.org/index.php/2013/09/08/opengl-es-2-basic-drawing/
 Part 3: ... not published yet ...
 */
@interface GLK2DrawCall : NSObject

/** Massively helpful when debugging: give each one a human-readable title */
@property(nonatomic,readonly) NSString* title;

@property(nonatomic) BOOL shouldClearColorBit, shouldClearDepthBit;

/** Every draw call MUST have a shaderprogram, or else it cannot draw objects nor pixels */
@property(nonatomic,retain) GLK2ShaderProgram* shaderProgram;

/** You nearly always want this on, so that overlapping triangles correctly overlap, instead of having one or the other
 overwriting the ones IN FRONT OF it */
@property(nonatomic) BOOL requiresDepthTest;

/** If this draw call has ANY geometry, it should go in a VBO (stores raw Vertex attributes),
 and the VBO should be embedded in a VAO (which stores the metadata about the geometry) */
@property(nonatomic,retain) GLK2VertexArrayObject* VAO;

/** i.e. GL_TRIANGLES, GL_TRIANGLE_STRIP, GL_TRIANGLE_FAN */
@property(nonatomic) GLuint glDrawCallType;

/** When you run a Draw call, it can optionally render anything from "0" up to "all" of the
 vertex-data stored in the VAO/VBO's.
 
 So ... OpenGL requires you to specify exactly how many vertices you want to use
 every time you Draw.
 
 It's easiest to save this number at the time you upload data into your VBO's (it IS possible
 to get the number back later - but your VBO's may (optionally) be different lengths, e.g. if
 you're sharing VBO's between multiple draw-calls. So you need to store the nubmer-to-draw
 on a per-drawcall basis.
 */
@property(nonatomic) GLuint numVerticesToDraw;

/** Each drawcall, this is inspected to calculate new values for every "uniform" in the pair of shaders */
@property(nonatomic,retain) NSObject<GLK2UniformValueGenerator>* uniformValueGenerator;

/** Textures in GL ES 2 are different from old-style OpenGL, and you MUST track the named
 shader-uniform / shader-sampler2d variable that each texture is 'attached' to; because of
 the way OpenGL handles texture-memory, you can't "do this once and forget about it", you
 have to keep re-doing it frame to frame */
@property(nonatomic,retain) NSMutableDictionary* texturesFromSamplers;

/**
 Defaults to:
 
 - clear color MAGENTA
 - depth test ON 
 
 ... everything else: OFF
 */
-(id) initWithTitle:(NSString*) title;

/**
 Delegates to initWithTitle, using a random string for the title
 */
- (id)init;

-(float*) clearColourArray;
-(void) setClearColourRed:(float) r green:(float) g blue:(float) b alpha:(float) a;

/** When the draw-call runs, it will look up all the 'sampler2D' objects in the Shader sourcecode,
 and then try to find an appropriate OpenGL Texture / GLK2Texture for each one.
 
 Make sure you call this method at least for each sampler in your shader (the contents are preserved
 even if you change shader-program at runtime, so you can have "more" of these mapped than necessary,
 if you want)
 
 @param texture if nil, will "remove" the sampler/texture pair from the mapping for this drawcall
 @return the OpenGL texture-unit that this drawcall wants to use for that texture
 */
-(GLuint) setTexture:(GLK2Texture*) texture forSampler:(GLK2Uniform*) sampler;
/**
 Convenience version of method that takes a name, and fetches the sampler for you */
-(GLuint) setTexture:(GLK2Texture*) texture forSamplerNamed:(NSString*) samplerName;

/** Massive bug in OpenGL API: ShaderPrograms DO NOT USE the correct texture-unit ID's (i.e. GL_TEXTURE0 etc)
 for identifying texture-units; instead, they use "the offset to add to GL_TEXTURE0"
 */
-(GLint)textureUnitOffsetForSampler:(GLK2Uniform *)sampler;

@end

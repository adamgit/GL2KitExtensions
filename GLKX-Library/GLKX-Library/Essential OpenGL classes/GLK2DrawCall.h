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

/** In almost all apps you want it ON */
@property(nonatomic) BOOL requiresCullFace;

/** Enabling this on Apple/PVR devices MASSIVELY reduces performance, so only use it when genuinely needed.
 
 Requires you to also set:
  - alphaBlendSourceFactor
  - alphaBlendDestinationFactor
 */
@property(nonatomic) BOOL requiresAlphaBlending;

/**
 For mode "requiresAlphaBlending = TRUE", defaults to: source = GL_ONE, dest = GL_ONE_MINUS_SRC_ALPHA
 */
@property(nonatomic) GLenum alphaBlendSourceFactor, alphaBlendDestinationFactor;

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

#pragma mark - All the possible Draw call types supported in GL ES 2

+(GLK2DrawCall*) drawCallPoints;
+(GLK2DrawCall*) drawCallLines;
+(GLK2DrawCall*) drawCallLineLoop;
+(GLK2DrawCall*) drawCallLineStrip;
+(GLK2DrawCall*) drawCallTriangles;
+(GLK2DrawCall*) drawCallTriangleStrip;
+(GLK2DrawCall*) drawCallTriangleFan;

#pragma mark - init methods

/**
 Defaults to:
 
 - clear color MAGENTA
 - depth test ON 
 - cull back-facing polygons ON
 
 ... everything else: OFF
 */
-(id) initWithTitle:(NSString*) title;

/**
 Delegates to initWithTitle, using a random string for the title
 */
- (id)init;

-(float*) clearColourArray;
-(void) setClearColourRed:(float) r green:(float) g blue:(float) b alpha:(float) a;

#pragma mark Missing GL methods for handling Uniforms in Shaders each frame

/** MUST be called AFTER setting this drawcall's shader to current
 (e.g. within the update / drawFrame loop)
 */
-(void) setAllUniformValuesForShader;

#pragma mark Texturing and texture-mapping methods

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

#pragma mark - workaround for bad OpenGL committee decisions

/**
 The OpenGL committee are sometimes evil - they decided to break GL ES so that VAO's
 can't be shared across threads.
 
 This also prevents you from loading background geometry. It's a MAJOR bug in the API.
 
 The only workaround is to load your geometry once, then clone your draw-calls, creating
 new VAO's, and re-assign the VBO's (which ARE shared) to the new VAO's on the new thread.
 */
-(id) copyDrawCallAllocatingNewVAO;

@end

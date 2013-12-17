#import "GLK2Texture.h"
#import <QuartzCore/QuartzCore.h>

@interface GLK2Texture (CoreGraphics)

/**
 1 of 2:
 
 Create a CGContext that you can convert into a texture.
 
 This creates the CPU-side memory and context
 */
+(CGContextRef) createCGContextForOpenGLTextureRGBAWidth:(int) width h:(int) height bitsPerPixel:(int) bpp shouldFlipY:(BOOL) flipY fillColorOrNil:(UIColor*) fillColor;

/**
 2 of 2:
 
 Convert a previously-created CGContext into an OpenGL texture, and upload to the GPU
 */
+(GLK2Texture*) uploadTextureRGBAToOpenGLFromCGContext:(CGContextRef) context width:(int)w height:(int)h;

@end

#import "CALayerTextureViewController.h"

#import "GLKX_Library.h"

#import "GLK2Texture.h"

#import "GLK2Texture+CoreGraphics.h"

#import "CommonGLEngineCode.h"

@interface CALayerTextureViewController ()

@end

@implementation CALayerTextureViewController

-(NSMutableArray*) createAllDrawCalls
{	
	/** All the local setup for the ViewController */
	NSMutableArray* result = [NSMutableArray array];
	
	/** -- Draw Call 1:
	 
	 triangle that contains a CALayer texture
	 */

	GLK2DrawCall* dcTri = [CommonGLEngineCode drawCallWithUnitTriangleAtOriginUsingShaders:
						   [GLK2ShaderProgram shaderProgramFromVertexFilename:@"VertexProjectedWithTexture" fragmentFilename:@"FragmentWithTexture"]];
	
	/** Do some drawing to a CGContextRef */
	CGContextRef cgContext = [GLK2Texture createCGContextForOpenGLTextureRGBAWidth:256 h:256 bitsPerPixel:8 shouldFlipY:FALSE fillColorOrNil:[UIColor blueColor]];
	CGContextSetFillColorWithColor( cgContext, [UIColor yellowColor].CGColor );
	CGContextFillEllipseInRect( cgContext, CGRectMake( 50, 50, 150, 150 ));
	
	/** Convert the CGContext into a GL texture */
	GLK2Texture* newTexture = [GLK2Texture uploadTextureRGBAToOpenGLFromCGContext:cgContext width:256 height:256];
	
	/** Add the GL texture to our Draw call / shader so it uses it */
	GLK2Uniform* samplerTexture1 = [dcTri.shaderProgram uniformNamed:@"s_texture1"];
	[dcTri setTexture:newTexture forSampler:samplerTexture1];
	
	/** Set the projection matrix to Identity (i.e. "dont change anything") */
	GLK2Uniform* uniProjectionMatrix = [dcTri.shaderProgram uniformNamed:@"projectionMatrix"];
	GLKMatrix4 rotatingProjectionMatrix = GLKMatrix4Identity;
	[dcTri.shaderProgram setValueOutsideRenderLoopRestoringProgramAfterwards:&rotatingProjectionMatrix forUniform:uniProjectionMatrix];
	
	[result addObject:dcTri];
	
	return result;
}

@end

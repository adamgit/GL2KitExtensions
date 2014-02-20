#import "AnimatedTextureViewController.h"

#import "GLKX_Library.h"

#import "GLK2Texture.h"
#import "GLK2UniformMapGenerator.h"
#import "CommonGLEngineCode.h"

@interface AnimatedTextureViewController ()
@property(nonatomic,retain) GLK2UniformMapGenerator* generator;
@end

@implementation AnimatedTextureViewController

-(NSMutableArray*) createAllDrawCalls
{	
	/** All the local setup for the ViewController */
	NSMutableArray* result = [NSMutableArray array];
	
	/** -- Draw Call 1:
	 
	 triangle that contains a CALayer texture
	 */

	GLK2DrawCall* dcTri = [CommonGLEngineCode drawCallWithUnitTriangleAtOriginUsingShaders:
						   [GLK2ShaderProgram shaderProgramFromVertexFilename:@"VertexProjectedWithTexture" fragmentFilename:@"FragmentTextureScrolling"]];
	
	self.generator = [GLK2UniformMapGenerator createAndAddToDrawCall:dcTri];
	
	/** Load a scales texture - I Googled "Public Domain Scales", you can probably find much better */
	GLK2Texture* newTexture = [GLK2Texture textureNamed:@"fakesnake.png"];
	/** Make the texture infinitely tiled */
	glBindTexture( GL_TEXTURE_2D, newTexture.glName);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	
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

-(void)willRenderDrawCallUsingVAOShaderProgramAndDefaultUniforms:(GLK2DrawCall *)drawCall
{
	/** Generate a smoothly increasing value using GLKit's built-in frame-count and frame-timers */
	double framesOutOfFramesPerSecond = (self.framesDisplayed % (4*self.framesPerSecond)) / (double)(4.0*self.framesPerSecond);
	
	[self.generator setFloat: framesOutOfFramesPerSecond named:@"timeInSeconds"];
}

@end

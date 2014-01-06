/**
 Introduced in: Part 7
 
 Requires you to add the CoreVideo framework to your project if you want to use this.
 */
#import "GLK2Texture.h"

@interface GLK2Texture (CoreVideo)

+(GLK2Texture*) texturePreCreatedByApplesCoreVideo:(CVOpenGLESTextureRef) applCoreVideoTexture;

/**
 THIS METHOD IS AGAINST THE ENTIRE ETHOS OF OPENGL, but Apple does some weird and crazy stuff
 inside CoreVideo, and refuses to document it - as a result, we HAVE to do this, or else we'll
 get memory leaks and app crashes and flickering etc.
 
 (basically: Apple trashes the GL textures, over and over again, at random rates, depending on
 how much CPU / GPU processing is happening in the background. NONE OF THIS IS DOCUMENTED!)
 
 Until Apple documents their shamefully obscure API (it's been 2 years now and we're all still waiting!)
 we have to accept that Apple "switches" the texture IDs of live textures around, and we have to
 follow suit. 
 */
-(void) liveAlterGLNameToWorkaroundAppleCoreVideoBug:(GLuint) newName;

@end

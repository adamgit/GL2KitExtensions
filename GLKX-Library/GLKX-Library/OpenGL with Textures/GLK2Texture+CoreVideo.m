#import "GLK2Texture+CoreVideo.h"

#import "GLK2Texture_MutableName.h"

@implementation GLK2Texture (CoreVideo)

+(GLK2Texture*) texturePreCreatedByApplesCoreVideo:(CVOpenGLESTextureRef) appleCoreVideoTexture
{
	GLK2Texture* newValue = [[[GLK2Texture alloc] initWithName:CVOpenGLESTextureGetName(appleCoreVideoTexture)]autorelease];
	
	return newValue;
}

-(void) liveAlterGLNameToWorkaroundAppleCoreVideoBug:(GLuint) newName
{
	self.glName = newName;
}

@end

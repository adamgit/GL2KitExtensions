/**
 ************************** WARNING *************************
 
 Code in this class is going beyond my intent of "just modify GLKit
 to add what's missing".
 
 This class contains methods and features you would expect to
 create when writing your own rendering-engine.
 
 I am including them here because they are CODE I ALREADY SHOWED
 in previous tutorials, and RE-USING THEM MAKES IT EASIER TO WRITE
 SHORT TUTORIALS going forwards.
 
 If you're doing your own 3D engine based on OpenGL - please throw-away
 this class!
 ************************** WARNING *************************
 
 In another sense ... the code in this class is stuff you used to find
 in OpenGL's "GLU" library, that was never officially part of GL itself,
 but was almost always available on every platform.
 
 GL ES implementations were shipped without GLU, partly because GLU relies
 upon lots of desktop-GL features that GL ES removed. This is a minor
 tragedy.
 
 This class is fine for demos and tutorials - but I RECOMMEND that you
 look for GLU source code online (it was most/all open-source) and port
 it to GL ES rather than use the crappy code contained in this class :).
 */
#import <Foundation/Foundation.h>

#import "GLK2DrawCall.h"
#import "GLK2ShaderProgram.h"

@interface CommonGLEngineCode : NSObject

+(GLK2DrawCall*) drawCallWithUnitTriangleAtOriginUsingShaders:(GLK2ShaderProgram*) shaderProgram;
+(GLK2DrawCall*) drawCallWithUnitCubeAtOriginUsingShaders:(GLK2ShaderProgram*) shaderProgram;

@end

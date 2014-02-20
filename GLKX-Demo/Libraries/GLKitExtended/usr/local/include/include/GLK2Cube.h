/**
 Apple has CGRect, and NSRect -- which use CGPoint and NSPoint
 Apple has NOTHING -- which uses GLKVector3
 
 ...but we need it whenever we talk about bounding-boxes in 3D, which is ...almost all the time!
 */
#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

typedef struct GLK2Cube
{
	GLKVector3 origin;
	GLKVector3 vectorAcross, vectorUp, vectorOut;
} GLK2Cube;

#pragma mark - NOTE: Apple doesn't provide a way for C projects/files to read the GLKit.h file, so we have to create a fake "class" to be allowed to write C functions

@interface FAKE_CLASS_TO_SATISFY_APPLE : NSObject

/**
 @param origin the "bottom left innermost corner" of the cube
 @param vAcross the vector in world space giving the cube's internal x-axis
 @param vUp the vector in world space giving the cube's internal y-axis
 @param vOut the vector in world space giving the cube's internal z-axis
 */
GLK2Cube GLK2CubeFromOriginAndBaseVectors( GLKVector3 o, GLKVector3 vAcross, GLKVector3 vUp, GLKVector3 vOut );

/**
 Returns a new cube with all base axes multiplied by the scalar
 */
GLK2Cube GLK2CubeMultiplyScalar( GLK2Cube oldCube, CGFloat scalar );

/**
 Adds offset to the cube's origin
 */
GLK2Cube GLK2CubeOffsetBy( GLK2Cube oldCube, GLKVector3 offset );

/**
 Takes the X, Y, and Z of vector, and multiplies the cube along its own axes by those
 amounts.
 
 e.g. for vector( 2, 1, 0 ), you get a new cube with cube.vectorAcross = 2* original,
 cube.vectorUp = original, and cube.vectorOut = 0
 */
GLK2Cube GLK2CubeMultiplyBaseVectors( GLK2Cube oldCube, GLKVector3 vector );

//NSString* NSStringFromGLK2Cube( GLK2Cube cube );

@end

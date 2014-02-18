#import "GLK2Cube.h"

@implementation FAKE_CLASS_TO_SATISFY_APPLE

GLK2Cube GLK2CubeFromOriginAndBaseVectors( GLKVector3 o, GLKVector3 vAcross, GLKVector3 vUp, GLKVector3 vOut )
{
	GLK2Cube cube = { o, vAcross, vUp, vOut };
	
	return cube;
}

GLK2Cube GLK2CubeMultiplyScalar( GLK2Cube oldCube, CGFloat scalar )
{
	GLK2Cube cube = { oldCube.origin,
		GLKVector3MultiplyScalar( oldCube.vectorAcross, scalar),
		GLKVector3MultiplyScalar( oldCube.vectorUp, scalar),
		GLKVector3MultiplyScalar( oldCube.vectorOut, scalar)
	};
	
	return cube;
}

GLK2Cube GLK2CubeMultiplyBaseVectors( GLK2Cube oldCube, GLKVector3 vector )
{
	GLK2Cube cube = { oldCube.origin,
		GLKVector3MultiplyScalar( oldCube.vectorAcross, vector.x ),
		GLKVector3MultiplyScalar( oldCube.vectorUp, vector.y ),
		GLKVector3MultiplyScalar( oldCube.vectorOut, vector.z )
	};
	
	return cube;
}

GLK2Cube GLK2CubeOffsetBy( GLK2Cube oldCube, GLKVector3 offset )
{
	GLK2Cube cube = { GLKVector3Add( oldCube.origin, offset ),
		oldCube.vectorAcross,
		oldCube.vectorUp,
		oldCube.vectorOut
	};
	
	return cube;
}

/*GLK2Cube GLK2CubeFromRect( GLKVector3 topLeft, GLKVector3 topRight, GLKVector3 bottomRight, GLKVector3 bottomLeft )
{
	GLK2Cube cube;
	
	
	return cube;
}*/

/*NSString* NSStringFromGLK2Cube( GLK2Cube cube )
{
	return [NSString stringWithFormat:@"{ %@, %@, %@, %@}", NSStringFromGLKVector3(cube.topLeft), NSStringFromGLKVector3(rect.topRight), NSStringFromGLKVector3(rect.bottomRight), NSStringFromGLKVector3(rect.bottomLeft) ];
}
*/
@end

#import "CommonGLEngineCode.h"

@implementation CommonGLEngineCode

+(GLK2DrawCall*) drawCallWithUnitTriangleAtOriginUsingShaders:(GLK2ShaderProgram*) shaderProgram
{
	GLK2DrawCall* dc = [[GLK2DrawCall new] autorelease];
	
	dc.shaderProgram = shaderProgram;
	
	/**   ... Make some geometry */
	
	GLfloat z = -0.0; // must be more than -1 * zNear, and ABS() less than zFar
	GLKVector3 cpuBuffer[3] = 
	{
		GLKVector3Make(-0.5,  -0.5, z),
		GLKVector3Make( 0,  -0.5, z),
		GLKVector3Make(-0.5, 0, z)
	};
	GLK2BufferObject* sharedVBOPositions = [GLK2BufferObject newVBOFilledWithData:cpuBuffer inFormat:[GLK2BufferFormat bufferFormatOneAttributeMadeOfGLFloats:3] numVertices:3 updateFrequency:GLK2BufferObjectFrequencyStatic];
	
	GLKVector2 attributesVirtualXY [3] = 
	{
		GLKVector2Make( 0, 0 ),
		GLKVector2Make( 1, 0 ),
		GLKVector2Make( 0, 1 )
	};
	GLK2BufferObject* sharedVBOVirtualXYs = [GLK2BufferObject newVBOFilledWithData:attributesVirtualXY inFormat:[GLK2BufferFormat bufferFormatOneAttributeMadeOfGLFloats:2] numVertices:3 updateFrequency:GLK2BufferObjectFrequencyStatic];
	
	GLK2Attribute* attPosition = [shaderProgram attributeNamed:@"position"]; // will fail if you haven't called glUseProgram yet
	GLK2Attribute* attXY = [shaderProgram attributeNamed:@"textureCoordinate"];
	
	dc.numVerticesToDraw = 3;
	dc.glDrawCallType = GL_TRIANGLES;
	
	dc.VAO = [[GLK2VertexArrayObject new] autorelease];
	[dc.VAO addVBO:sharedVBOPositions forAttributes:@[attPosition] numVertices:3];
	if( attXY != nil )
		[dc.VAO addVBO:sharedVBOVirtualXYs forAttributes:@[attXY] numVertices:3];
	
	return dc;
	
}

+(GLK2DrawCall*) drawCallWithUnitCubeAtOriginUsingShaders:(GLK2ShaderProgram*) shaderProgram
{
	GLK2DrawCall* dc = [[GLK2DrawCall new] autorelease];
	
	dc.shaderProgram = shaderProgram;
	
	/**   ... Make some geometry */
	
	GLKVector3 cpuBuffer[36] = 
	{
		// bottom
		GLKVector3Make(-0.5,-0.5, -0.5),
		GLKVector3Make( 0.5, 0.5, -0.5),
		GLKVector3Make( 0.5,-0.5, -0.5),
		GLKVector3Make(-0.5,-0.5, -0.5),
		GLKVector3Make(-0.5, 0.5, -0.5),
		GLKVector3Make( 0.5, 0.5, -0.5),
		
		// top
		GLKVector3Make(-0.5,-0.5, 0.5),
		GLKVector3Make( 0.5,-0.5, 0.5),
		GLKVector3Make( 0.5, 0.5, 0.5),
		GLKVector3Make(-0.5,-0.5, 0.5),
		GLKVector3Make( 0.5, 0.5, 0.5),
		GLKVector3Make(-0.5, 0.5, 0.5),
		
		// north
		GLKVector3Make(-0.5, 0.5,-0.5),
		GLKVector3Make( 0.5, 0.5, 0.5),
		GLKVector3Make( 0.5, 0.5,-0.5),
		GLKVector3Make(-0.5, 0.5,-0.5),
		GLKVector3Make(-0.5, 0.5, 0.5),
		GLKVector3Make( 0.5, 0.5, 0.5),
		
		// south
		GLKVector3Make(-0.5, -0.5,-0.5),
		GLKVector3Make( 0.5, -0.5,-0.5),
		GLKVector3Make( 0.5, -0.5, 0.5),
		GLKVector3Make(-0.5, -0.5,-0.5),
		GLKVector3Make( 0.5, -0.5, 0.5),
		GLKVector3Make(-0.5, -0.5, 0.5),
		
		// east
		GLKVector3Make( 0.5,-0.5,-0.5),
		GLKVector3Make( 0.5, 0.5,-0.5),
		GLKVector3Make( 0.5, 0.5, 0.5),
		GLKVector3Make( 0.5,-0.5,-0.5),
		GLKVector3Make( 0.5, 0.5, 0.5),
		GLKVector3Make( 0.5,-0.5, 0.5),
		
		// west
		GLKVector3Make(-0.5,-0.5,-0.5),
		GLKVector3Make(-0.5, 0.5, 0.5),
		GLKVector3Make(-0.5, 0.5,-0.5),
		GLKVector3Make(-0.5,-0.5,-0.5),
		GLKVector3Make(-0.5,-0.5, 0.5),
		GLKVector3Make(-0.5, 0.5, 0.5),
	};
	GLK2BufferObject* sharedVBOPositions = [GLK2BufferObject newVBOFilledWithData:cpuBuffer inFormat:[GLK2BufferFormat bufferFormatOneAttributeMadeOfGLFloats:3] numVertices:36 updateFrequency:GLK2BufferObjectFrequencyStatic];
	
	GLKVector2 attributesVirtualXY [36] = 
	{
		GLKVector2Make( 0, 0 ),
		GLKVector2Make( 1, 1 ),
		GLKVector2Make( 1, 0 ),
		GLKVector2Make( 0, 0 ),
		GLKVector2Make( 0, 1 ),
		GLKVector2Make( 1, 1 ),
		
		GLKVector2Make( 0, 0 ),
		GLKVector2Make( 1, 0 ),
		GLKVector2Make( 1, 1 ),
		GLKVector2Make( 0, 0 ),
		GLKVector2Make( 1, 1 ),
		GLKVector2Make( 0, 1 ),
		
		GLKVector2Make( 0, 0 ),
		GLKVector2Make( 1, 1 ),
		GLKVector2Make( 0, 1 ),
		GLKVector2Make( 0, 0 ),
		GLKVector2Make( 1, 0 ),
		GLKVector2Make( 1, 1 ),
		
		GLKVector2Make( 0, 0 ),
		GLKVector2Make( 1, 0 ),
		GLKVector2Make( 1, 1 ),
		GLKVector2Make( 0, 0 ),
		GLKVector2Make( 1, 1 ),
		GLKVector2Make( 0, 1 ),
		
		GLKVector2Make( 0, 0 ),
		GLKVector2Make( 1, 0 ),
		GLKVector2Make( 1, 1 ),
		GLKVector2Make( 0, 0 ),
		GLKVector2Make( 1, 1 ),
		GLKVector2Make( 0, 1 ),
		
		GLKVector2Make( 0, 0 ),
		GLKVector2Make( 1, 1 ),
		GLKVector2Make( 0, 1 ),
		GLKVector2Make( 0, 0 ),
		GLKVector2Make( 1, 0 ),
		GLKVector2Make( 1, 1 ),
	};
	
	GLK2BufferObject* sharedVBOVirtualXYs = [GLK2BufferObject newVBOFilledWithData:attributesVirtualXY inFormat:[GLK2BufferFormat bufferFormatOneAttributeMadeOfGLFloats:2] numVertices:36 updateFrequency:GLK2BufferObjectFrequencyStatic];
	
	GLK2Attribute* attPosition = [shaderProgram attributeNamed:@"position"]; // will fail if you haven't called glUseProgram yet
	GLK2Attribute* attXY = [shaderProgram attributeNamed:@"textureCoordinate"];
	
	dc.numVerticesToDraw = 36;
	dc.glDrawCallType = GL_TRIANGLES;
	dc.VAO = [[GLK2VertexArrayObject new] autorelease];
	[dc.VAO addVBO:sharedVBOPositions forAttributes:@[attPosition] numVertices:3];
	if( attXY != nil )
		[dc.VAO addVBO:sharedVBOVirtualXYs forAttributes:@[attXY] numVertices:3];
	
	return dc;
}

@end

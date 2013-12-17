attribute vec4 position;
attribute vec2 textureCoordinate;

varying mediump vec2 varyingtextureCoordinate;

/** In old desktop terms, this is the MVP matrix, pre-multiplied on the CPU.
 Useless in general apps, but perfect for simple apps */
uniform mediump mat4 projectionMatrix;

void main()
{
	/** outputs: */
	varyingtextureCoordinate = textureCoordinate;
	gl_Position = projectionMatrix * position;
	//gl_Position = mat4( 1.0, 0, 0, 0, 0, 1.0, 0, 0, 0, 0, 1.0, 0, 0, 0, 0, 1.0 ) * position;
	//gl_Position = position * projectionMatrix;
	//gl_Position = position;
}
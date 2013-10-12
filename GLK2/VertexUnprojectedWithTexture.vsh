attribute vec4 position;
attribute vec2 textureCoordinate;

varying mediump vec2 varyingtextureCoordinate;

void main()
{
	/** outputs: */
	varyingtextureCoordinate = textureCoordinate;
	gl_Position = position;
}
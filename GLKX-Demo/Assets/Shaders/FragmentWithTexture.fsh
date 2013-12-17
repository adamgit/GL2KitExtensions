varying mediump vec2 varyingtextureCoordinate;

uniform sampler2D s_texture1;

void main()
{
	/** outputs: */
	gl_FragColor = texture2D( s_texture1, varyingtextureCoordinate );
}
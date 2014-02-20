uniform mediump float timeInSeconds;

varying mediump vec2 varyingtextureCoordinate;

uniform sampler2D s_texture1;

void main()
{
	/** Let's do something interesting with the virtual X, Y we've been given */
	
	mediump vec2 texCoordOverTime = vec2( varyingtextureCoordinate.x, varyingtextureCoordinate.y + timeInSeconds );
	
	gl_FragColor = texture2D( s_texture1, texCoordOverTime );
}

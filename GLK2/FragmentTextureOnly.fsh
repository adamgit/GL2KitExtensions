varying mediump vec2 varyingtextureCoordinate;

uniform sampler2D s_texture1;
uniform mediump float textureOffsetU;

void main()
{	
	/** outputs: */
	gl_FragColor = texture2D( s_texture1, vec2( varyingtextureCoordinate.x + textureOffsetU, varyingtextureCoordinate.y) );
	//DEBUG: gl_FragColor = vec4( 0.0, 0.0, 1.0, 1.0 );
}

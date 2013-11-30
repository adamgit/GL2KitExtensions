varying mediump vec2 varyingtextureCoordinate;

uniform sampler2D s_texture1, s2;
uniform mediump float textureOffsetU;

void main()
{	
	/** outputs: */
	mediump vec4 topcolour = texture2D( s2, vec2( varyingtextureCoordinate.x + textureOffsetU, varyingtextureCoordinate.y) );
	mediump vec4 botcolour = texture2D( s_texture1, vec2( varyingtextureCoordinate.x + textureOffsetU, varyingtextureCoordinate.y) );
	
	gl_FragColor = mix( topcolour, botcolour, varyingtextureCoordinate.y);
	
	//CORRECT: gl_FragColor = texture2D( s_texture1, vec2( varyingtextureCoordinate.x + textureOffsetU, varyingtextureCoordinate.y) );
	//DEBUG: gl_FragColor = vec4( 0.0, 0.0, 1.0, 1.0 );
}

uniform sampler2D s_texture; // this name MUST match the one used for "uniformNamed:" above
varying mediump vec2 v_virtualXY; // MUST match the one in Vertex Shader

void main()
{
	gl_FragColor = texture2D( s_texture, v_virtualXY );
}

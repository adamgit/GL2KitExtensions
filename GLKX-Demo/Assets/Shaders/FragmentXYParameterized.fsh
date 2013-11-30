varying mediump vec2 v_virtualXY;

void main()
{
	/** Let's do something interesting with the virtual X, Y we've been given */
	
	mediump float red, green, blue; // some Local variables. Inefficient, but makes code easier to read
	red = green = blue = sin( v_virtualXY.x ) + sin( v_virtualXY.y );
	blue *= cos( v_virtualXY.y );
	
	gl_FragColor = vec4( red, green, blue, 1.0 );
}

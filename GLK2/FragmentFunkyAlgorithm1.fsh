uniform mediump float timeInSeconds;

varying mediump float v_algorithmVirtualX, v_algorithmVirtualY;

#define PI 3.14145926 // GLSL / shaders don't have PI in the language! We have to write it ourselves...

void main()
{
	/** Let's do something interesting with the virtual X, Y we've been given */
	
	mediump float xInTime = v_algorithmVirtualX + timeInSeconds;
	
	mediump float waves1 = 0.5 + 0.5 * sin( cos(10.0 * xInTime) + 2.0 * PI * ( 1.0 * v_algorithmVirtualX*v_algorithmVirtualX + v_algorithmVirtualY));
	
	mediump float theta = 0.5 + 0.5 * cos( 2.0 * PI * v_algorithmVirtualX ) * sin( 2.0 * PI * v_algorithmVirtualY );
	
	mediump float thetaed = theta ;
	
	gl_FragColor = vec4( sin(timeInSeconds) * waves1, waves1, cos(1.1*timeInSeconds) * sqrt(waves1) + waves1, 1.0 );
}

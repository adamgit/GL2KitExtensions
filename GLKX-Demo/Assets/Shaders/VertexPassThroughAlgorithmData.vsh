uniform mediump float timeInSeconds;

attribute vec4 position;
attribute float algorithmVirtualX, algorithmVirtualY;

varying mediump float v_algorithmVirtualX, v_algorithmVirtualY;

void main()
{
	/** This LOOKS LIKE an assignment, but the magic of Vertex -> Fragment shaders
	 is that as soon as we write a value into a "varying", it gets converted into
	 an "interpolated copy of that value, that is automatically interpolated for
	 each pixel in the fragment shader"
	 */
	v_algorithmVirtualX = algorithmVirtualX;
	v_algorithmVirtualY = algorithmVirtualY;
	
	gl_Position = position;
}
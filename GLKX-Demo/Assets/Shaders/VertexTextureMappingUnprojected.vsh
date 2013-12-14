attribute vec4 position;
attribute vec2 a_virtualXY;

varying mediump vec2 v_virtualXY;

void main()
{
	v_virtualXY = a_virtualXY;
	gl_Position = position;
}

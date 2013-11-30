attribute vec4 position;
attribute vec2 virtualXY;

uniform vec2 positionOffset;

varying mediump vec2 v_virtualXY;

void main()
{
	v_virtualXY = 3.1415926 * (2.0 * virtualXY) - 3.1415926;
	gl_Position = position + vec4( positionOffset, 0, 0 );
}
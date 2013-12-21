/** Based on Apple's code:
 https://developer.apple.com/library/ios/samplecode/GLCameraRipple/Listings/GLCameraRipple_Shaders_Shader_fsh.html#//apple_ref/doc/uid/DTS40011222-GLCameraRipple_Shaders_Shader_fsh-DontLinkElementID_9
 */
varying mediump vec2 varyingtextureCoordinate;

uniform sampler2D s_texture1, s_texture2;

void main()
{
	mediump vec3 yuv;
	lowp vec3 rgb;
	
	yuv.x = texture2D(s_texture1, varyingtextureCoordinate).r;
	yuv.yz = texture2D(s_texture2, varyingtextureCoordinate).rg - vec2(0.5, 0.5);
	
	
    // BT.601, which is the standard for SDTV is provided as a reference
    /*
	 rgb = mat3(    1,       1,     1,
	 0, -.34413, 1.772,
	 1.402, -.71414,     0) * yuv;
	 */
	
	
    // Using BT.709 which is the standard for HDTV
    rgb = mat3(      1,       1,      1,
			   0, -.18732, 1.8556,
	           1.57481, -.46813,      0) * yuv;
	
    gl_FragColor = vec4(rgb, 1);
}
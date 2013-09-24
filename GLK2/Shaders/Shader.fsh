//
//  Shader.fsh
//  GLK2
//
//  Created by adam on 03/09/2013.
//
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}

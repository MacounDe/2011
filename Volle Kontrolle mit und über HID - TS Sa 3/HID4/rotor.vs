varying vec2 tc;
varying vec3 normal;
uniform float anim;
varying vec4 lightPos;

void main()
{
	gl_FrontColor = gl_Color;
	tc = gl_MultiTexCoord0.xy;
	normal = gl_NormalMatrix * gl_Normal;
	lightPos = gl_LightSource[0].position;
	gl_Position = ftransform();
}

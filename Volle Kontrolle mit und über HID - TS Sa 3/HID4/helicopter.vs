varying vec3 vertexNormal;
varying vec2 tc;
varying vec4 lightPos;

void main() {
	gl_FrontColor = gl_Color;
	tc = gl_MultiTexCoord0.xy;
	vertexNormal = normalize(gl_NormalMatrix * gl_Normal);
	lightPos = gl_LightSource[0].position;
	gl_Position = ftransform();
}

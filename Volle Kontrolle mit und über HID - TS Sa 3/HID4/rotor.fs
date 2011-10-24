varying vec2 tc;
varying vec3 normal;
uniform	float anim;
varying vec4 lightPos;
void main()
{

	vec2 centered = vec2(2.0*tc.x-1.0 , 2.0*tc.y-1.0);
	float ang = pow(max(0.0,sin(anim+2.0*atan(centered.x, centered.y))),4.0);
	float rad = 1.0-step(1.0,sqrt(centered.x*centered.x + centered.y*centered.y)); 
	float alpha = ang * rad;
	vec3 color = vec3(1.0,1.0,1.0);
	vec3 norm = normalize(normal);
	vec3 lightDir = normalize(lightPos.xyz);
	float diffuse = max(0.0,dot(norm,lightDir));
	float lighting = 0.2 + 0.8 * diffuse;
	color = color * lighting;
	gl_FragColor = vec4(color,alpha);
}

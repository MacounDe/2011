uniform sampler2D tex;
varying vec3 vertexNormal;
varying vec2 tc;
varying vec4 lightPos;

void main()
{
	bool window = (tc.y > 0.6);
	bool stripe1 = ((tc.y > 0.15) && (tc.y < 0.17));
	bool stripe2 = ((tc.y > 0.44) && (tc.y < 0.46));
	bool stripe = stripe1 || stripe2;
	
	vec3 color = vec3(0.8,0.8,0.8); 
	color = stripe ? vec3(0.9,0.2,0.2) : color; 
	color = window ? vec3(0.0,0.0,0.0) : color;
	//lighting
	vec3 norm = normalize(vertexNormal);
	vec3 lightDir = normalize(lightPos.xyz);
	float diffuse = max(dot(norm, lightDir), 0.0);
	float lighting = 0.3 + 0.7 * diffuse;
	color *= lighting;
	
	gl_FragColor = vec4(color,1.0);
}

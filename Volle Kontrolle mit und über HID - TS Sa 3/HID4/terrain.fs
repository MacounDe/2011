#extension GL_EXT_gpu_shader4: enable

varying vec4 worldPos;
uniform sampler2D tex;
uniform sampler2D envMap;
uniform sampler2D noiseTex;
uniform sampler1D heightColorMap;
uniform vec2 texScale;			//scale from world x/z to tex s/t (radius, always centered)
uniform vec2 heightSealevel;	//scale of heightmap, offset (after scale)
uniform vec3 camPos;
varying vec4 lightPos;

const float TEX_DELTA = 2.0;
const float NORMAL_STRENGTH = 0.3;
const float NOISE_SCALE = 200.0;
const float NOISE_LAND_STRENGTH = 0.08;
const float BUMP_STRENGTH = 0.4;


void main() {
	//determine base color
	float height = worldPos.y;
	bool land = (height >= 0.0);
	float heightLookup = (height+heightSealevel.y)/heightSealevel.x + (land ? 0.0002 : -0.0002);
	vec3 color = texture1D(heightColorMap, heightLookup ).xyz;

    //make some noise
    vec3 noise = texture2D(noiseTex,worldPos.xz / NOISE_SCALE ).xyz;
	//add noise, calculate normal
	vec3 normal;
	if (land) {
		color += NOISE_LAND_STRENGTH * noise.x;
		float hx0 = texture2D(tex, vec2((worldPos.x-TEX_DELTA)*0.5/texScale.x+0.5,(worldPos.z)*0.5/texScale.y+0.5)).x;
		float hx1 = texture2D(tex, vec2((worldPos.x+TEX_DELTA)*0.5/texScale.x+0.5,(worldPos.z)*0.5/texScale.y+0.5)).x;
		float hz0 = texture2D(tex, vec2((worldPos.x)*0.5/texScale.x+0.5,(worldPos.z-TEX_DELTA)*0.5/texScale.y+0.5)).x;
		float hz1 = texture2D(tex, vec2((worldPos.x)*0.5/texScale.x+0.5,(worldPos.z+TEX_DELTA)*0.5/texScale.y+0.5)).x;
		normal = normalize(vec3(heightSealevel.x*NORMAL_STRENGTH*(hx0-hx1)+BUMP_STRENGTH*(noise.y-0.5),
								1.0,
								heightSealevel.x*NORMAL_STRENGTH*(hz0-hz1))+BUMP_STRENGTH*(noise.z-0.5));
	} else {
		color += 0.06* noise.x;
		normal = vec3(0.0,1.0,0.0);
	}

	//illumination
	vec3 lightDir = normalize(lightPos.xyz);
	float diffFac = 0.8;
	float ambFac = 0.2;
	float diff = max(0.0,dot(normal, lightDir));
	float illum = diffFac * diff + ambFac;
	color = illum * color; 

	//water reflection or fog
	if (!land) {
		vec3 inDir = normalize(vec3(worldPos.x,0.0,worldPos.z) - camPos);
		float alpha = atan(inDir.x,inDir.z);
		float beta = acos(-inDir.y);
		float rad = beta * 0.32;
		
		vec2 envCoord = vec2(0.5 + rad*sin(alpha), 0.5 + rad*cos(alpha));
		vec3 envColor = texture2D(envMap, envCoord).xyz;
		color += 0.8*pow(beta/1.57,4.0) * envColor;
	} 
	//add fog
	vec3 fogColor = vec3(0.2,0.3,0.4);
	float fogStrength = clamp((gl_FragCoord.z-0.97)*20.0,0.0,1.0);
	color = mix(color, fogColor, fogStrength);

	gl_FragColor = vec4(color,1.0);
}



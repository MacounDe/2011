#extension GL_EXT_gpu_shader4: enable

uniform vec4 offScale;	//off x, off z, scale x, scale z
uniform vec2 texScale;	//scale from world x/z to tex s/t (radius, always centered)
uniform vec2 heightSealevel;	//scale of heightmap, offset (after scale)
uniform sampler2D tex;

varying vec4 worldPos;
varying vec4 lightPos;

#define SUBSEALEVEL_THRESHOLD -1.0

void main() {
	vec4 pos = vec4(gl_Vertex.x*offScale.z+offScale.x,
					gl_Vertex.y,
					gl_Vertex.z*offScale.w+offScale.y,
					gl_Vertex.w);
	vec2 texCoord = vec2(pos.x*0.5/texScale.x+0.5,pos.z*0.5/texScale.y+0.5);
	pos.y = texture2D(tex, texCoord).x * heightSealevel.x - heightSealevel.y;
	worldPos = pos;
	pos.y = max(SUBSEALEVEL_THRESHOLD, pos.y);
	lightPos = gl_LightSource[1].position;	//in our world coordinates
	gl_Position = gl_ModelViewProjectionMatrix * pos;

}

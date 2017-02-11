#vertex shader

uniform mat4 MVP;

void main() {

	gl_Position     = MVP*gl_Vertex;
	gl_TexCoord [0] = gl_MultiTexCoord0;

}

#fragment shader

uniform sampler2D Texture;
uniform sampler2D Mask;
uniform vec2      Offset;
uniform vec2      Size;
uniform vec2      MaskOffset;
uniform vec2      MaskSize;
uniform float     Alpha;

void main() {

	vec2 texc    = vec2      (gl_TexCoord[0].x*Size[0]+Offset[0], gl_TexCoord[0].y*Size[1]+Offset[1]);
	vec4 tex     = texture2D (Texture, texc);

	vec2 atexc   = vec2      (gl_TexCoord[0].x*MaskSize[0]+MaskOffset[0], gl_TexCoord[0].y*MaskSize[1]+MaskOffset[1]);
	vec4 maskTex = texture2D (Mask, atexc);

	gl_FragColor = vec4(vec3(tex), tex.a*maskTex.r*Alpha);

}

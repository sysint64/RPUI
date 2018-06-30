#vertex shader

uniform mat4 MVP;

void main() {
    gl_Position = MVP*gl_Vertex;
    gl_TexCoord[0] = gl_MultiTexCoord0;
}

#fragment shader

uniform sampler2D texture;
uniform vec2 texOffset;
uniform vec2 texSize;
uniform vec4 color;

void main() {
    vec2 texc = vec2(gl_TexCoord[0].x*texSize[0]+texOffset[0],
                     gl_TexCoord[0].y*texSize[1]+texOffset[1]);
    vec4 tex = texture2D (texture, texc);
    gl_FragColor = tex * color;
}

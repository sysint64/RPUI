#vertex shader

uniform mat4 MVP;

void main() {
    gl_Position = MVP * gl_Vertex;
    gl_TexCoord[0] = gl_MultiTexCoord0;
}

#fragment shader

uniform sampler2D texture;

void main() {
    vec2 texc = vec2(gl_TexCoord[0].x, gl_TexCoord[0].y);
    vec4 tex = texture2D(texture, texc);
    gl_FragColor = tex;
}

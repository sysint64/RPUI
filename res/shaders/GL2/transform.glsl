#vertex shader

uniform mat4 MVP;

void main() {
    vec4 position = gl_Vertex;

    gl_Position = MVP*position;
    gl_TexCoord[0] = gl_MultiTexCoord0;
}

#fragment shader

uniform sampler2D texture;
uniform vec4 texCoord;

void main() {
    float un = texCoord.x/128.0;
    float vn = texCoord.y/128.0;

    float us = texCoord.z/128.0;
    float vs = texCoord.w/128.0;

    vec2 texc = vec2(gl_TexCoord[0].x*us+un,
                     gl_TexCoord[0].y*vs+vn);
    vec4 tex = texture2D(texture, texc)*vec4(0.0f, 0.0f, 0.0f, 1.0f);
    gl_FragColor = tex;
}

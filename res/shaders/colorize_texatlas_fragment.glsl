#version 430 core

precision highp float;
out vec4 fragColor;
in vec2 texCoord;

uniform sampler2D texture;
uniform vec2 texOffset;
uniform vec2 texSize;
uniform vec4 color;

void main() {
    vec2 texc = vec2(
        texCoord.x*texSize[0]+texOffset[0],
        texCoord.y*texSize[1]+texOffset[1]
    );

    vec4 tex = texture2D(texture, texc);
    fragColor = tex * color;
}

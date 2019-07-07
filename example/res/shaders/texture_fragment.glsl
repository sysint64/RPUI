#version 430 core

precision highp float;
out vec4 fragColor;
in vec2 texCoord;

uniform sampler2D texture;

void main() {
    vec4 tex = texture2D(texture, texCoord);
    fragColor = tex;
}

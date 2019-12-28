#version 410 core

precision highp float;
out vec4 fragColor;
in vec2 texCoord;

uniform sampler2D utexture;

void main() {
    vec4 tex = texture(utexture, texCoord);
    fragColor = tex;
}

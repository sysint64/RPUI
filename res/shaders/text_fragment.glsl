#version 410 core

precision highp float;
out vec4 fragColor;
in vec2 texCoord;

uniform sampler2D utexture;
uniform vec4 color;

void main() {
    vec4 tex = texture(utexture, texCoord);
    fragColor = vec4(1.0 - tex.r, 1.0 - tex.g, 1.0 - tex.b, tex.a) * color;
}

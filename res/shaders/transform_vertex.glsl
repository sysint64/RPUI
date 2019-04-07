#version 430 core

layout (location = 0) in vec3 in_Position;
layout (location = 1) in vec2 in_TexCoord;

uniform mat4 MVP;
out vec2 texCoord;

void main() {
    gl_Position = MVP*vec4(in_Position, 1.0);
    texCoord = in_TexCoord.xy;
}

#vertex shader

uniform mat4 MVP;

void main() {
	gl_Position = MVP*gl_Vertex;
}

#fragment shader

uniform vec4 Color;

void main() {
	gl_FragColor = Color;
}

#vertex shader

uniform mat4 cameraScaleMatrix;
uniform mat4 rotateMatrix;
uniform mat4 translateMatrix;
uniform mat4 scaleMatrix;
uniform mat4 projectionMatrix;
uniform mat4 viewMatrix;

void main() {
    mat4 modelMatrix = translateMatrix * rotateMatrix * scaleMatrix;
    mat4 cameraMVP = projectionMatrix * cameraScaleMatrix * viewMatrix;
    gl_Position = cameraMVP * modelMatrix * gl_Vertex;
    gl_TexCoord[0] = gl_MultiTexCoord0;
}

#fragment shader

uniform sampler2D texture;

void main() {
    vec2 texc = vec2(gl_TexCoord[0].x, gl_TexCoord[0].y);
    vec4 tex = texture2D(texture, texc);
    gl_FragColor = tex;
}

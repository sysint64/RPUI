module rpui.renderer;

import std.math;

import gapi.vec;
import gapi.transform;
import gapi.shader;
import gapi.shader_uniform;
import gapi.texture;
import gapi.geometry;
import gapi.geometry_quad;
import gapi.opengl;

import rpui.events;
import rpui.theme;
import rpui.widget;
import rpui.render_objects;

struct StatefulTextureHorizontalChainMeasure {
    StatefulTextureQuad[ChainPart] parts;
    float leftWidth;
    float rightWidth;
    float centerWidth;
    vec2 leftPos;
    vec2 centerPos;
    vec2 rightPos;
}

StatefulTextureHorizontalChainMeasure measureStatefulTextureHorizontalChain(
    StatefulTextureQuad[ChainPart] parts,
    in CameraView cameraView,
    in vec2 position,
    in vec2 size,
    in State state,
    in Widget.PartDraws partDraws
) {
    StatefulTextureHorizontalChainMeasure measure;

    measure.leftWidth = parts[ChainPart.left].texCoords[state].size.x;
    measure.rightWidth = parts[ChainPart.right].texCoords[state].size.x;
    measure.centerWidth = size.x - measure.leftWidth - measure.rightWidth;

    measure.leftPos = position;
    measure.centerPos = measure.leftPos + vec2(measure.leftWidth, 0);
    measure.rightPos = measure.centerPos + vec2(measure.centerWidth, 0);

    switch (partDraws) {
        case Widget.PartDraws.left:
            break;

        case Widget.PartDraws.center:
            parts[ChainPart.center] = measureStatefulTextureQuad(
                parts[ChainPart.center],
                cameraView,
                position,
                size
            );
            break;

        case Widget.PartDraws.right:
            break;

        default:
            break;
    }

    return measure;
}

void renderStatefulTextureHorizontalChain(
    in Theme theme,
    in RenderEvent event,
    StatefulTextureQuad[ChainPart] parts,
    in vec2 position,
    in vec2 size,
    in State state,
    in Widget.PartDraws partDraws
) {
    const leftWidth = parts[ChainPart.left].texCoords[state].size.x;
    const rightWidth = parts[ChainPart.right].texCoords[state].size.x;
    const centerWidth = size.x - leftWidth - rightWidth;

    const leftPos = position;
    const centerPos = leftPos + vec2(leftWidth, 0);
    const rightPos = centerPos + vec2(centerWidth, 0);

    switch (partDraws) {
        case Widget.PartDraws.left:
            break;

        case Widget.PartDraws.center:
            renderStatefulTextureQuad(
                event,
                parts[ChainPart.center],
                theme.shaders.textureAtlasShader,
                leftPos,
                vec2(leftWidth + centerWidth + rightWidth, size.y),
                state
            );
            break;

        case Widget.PartDraws.right:
            break;

        default:
            break;
    }
}

StatefulTextureQuad measureStatefulTextureQuad(
    StatefulTextureQuad quad,
    in CameraView cameraView,
    in vec2 position,
    in vec2 size
) {
    quad.transform.position = toScreenPosition(cameraView.viewportHeight, position, size);
    quad.transform.scaling = size;
    quad.modelMatrix = create2DModelMatrix(quad.transform);
    quad.mvpMatrix = cameraView.mvpMatrix * quad.modelMatrix;

    return quad;
}

void renderStatefulTextureQuad(
    in RenderEvent event,
    StatefulTextureQuad quad,
    in ShaderProgram shader,
    vec2 position,
    vec2 size,
    State state
) {
    quad.transform.position = toScreenPosition(event.viewportHeight, position, size);
    quad.transform.scaling = size;
    quad.modelMatrix = create2DModelMatrix(quad.transform);
    quad.mvpMatrix = event.camertMVPMatrix * quad.modelMatrix;

    bindShaderProgram(shader);

    const texCoord = quad.texCoords[state];

    setShaderProgramUniformMatrix(shader, "MVP", quad.mvpMatrix);
    setShaderProgramUniformTexture(shader, "texture", quad.texture, 0);
    setShaderProgramUniformVec2f(shader,"texOffset", texCoord.offset);
    setShaderProgramUniformVec2f(shader,"texSize", texCoord.size);
    setShaderProgramUniformFloat(shader, "alpha", 1.0f);

    bindVAO(quad.geometry.vao);
    bindIndices(quad.geometry.indicesBuffer);
    renderIndexedGeometry(cast(uint) quadIndices.length, GL_TRIANGLE_STRIP);
}

vec2 toScreenPosition(in float windowHeight, in vec2 position, in vec2 size) {
    return vec2(floor(position.x), floor(windowHeight - size.y - position.y));
}

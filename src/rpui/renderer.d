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
    QuadMeasure[ChainPart] measureParts;
}

StatefulTextureHorizontalChainMeasure measureStatefulTextureHorizontalChain(
    in StatefulTextureQuad[ChainPart] parts,
    in CameraView cameraView,
    in vec2 position,
    in vec2 size,
    in State state,
    in Widget.PartDraws partDraws
) {
    StatefulTextureHorizontalChainMeasure measure;

    const leftWidth = parts[ChainPart.left].texCoords[state].size.x;
    const rightWidth = parts[ChainPart.right].texCoords[state].size.x;
    const centerWidth = size.x - leftWidth - rightWidth;

    const leftPos = position;
    const centerPos = leftPos + vec2(leftWidth, 0);
    const rightPos = centerPos + vec2(centerWidth, 0);

    switch (partDraws) {
        case Widget.PartDraws.left:
            measure.measureParts[ChainPart.left] = measureStatefulTextureQuad(
                cameraView,
                leftPos,
                vec2(leftWidth, size.y)
            );
            measure.measureParts[ChainPart.center] = measureStatefulTextureQuad(
                cameraView,
                centerPos,
                vec2(centerWidth + rightWidth, size.y)
            );
            break;

        case Widget.PartDraws.center:
            measure.measureParts[ChainPart.center] = measureStatefulTextureQuad(
                cameraView,
                position,
                size
            );
            break;

        case Widget.PartDraws.right:
            measure.measureParts[ChainPart.center] = measureStatefulTextureQuad(
                cameraView,
                leftPos,
                vec2(centerWidth + leftWidth, size.y)
            );
            measure.measureParts[ChainPart.right] = measureStatefulTextureQuad(
                cameraView,
                rightPos,
                vec2(rightWidth, size.y)
            );
            break;

        default:
            measure.measureParts[ChainPart.left] = measureStatefulTextureQuad(
                cameraView,
                leftPos,
                vec2(leftWidth, size.y)
            );
            measure.measureParts[ChainPart.center] = measureStatefulTextureQuad(
                cameraView,
                centerPos,
                vec2(centerWidth, size.y)
            );
            measure.measureParts[ChainPart.right] = measureStatefulTextureQuad(
                cameraView,
                rightPos,
                vec2(rightWidth, size.y)
            );
            break;
    }

    return measure;
}

void renderStatefulTextureHorizontalChain(
    in Theme theme,
    in StatefulTextureQuad[ChainPart] parts,
    in StatefulTextureHorizontalChainMeasure measure,
    in State state,
    in Widget.PartDraws partDraws
) {
    if (partDraws == Widget.PartDraws.left || partDraws == Widget.PartDraws.all) {
        renderStatefulTextureQuad(
            parts[ChainPart.left],
            measure.measureParts[ChainPart.left],
            theme.shaders.textureAtlasShader,
            state
        );
    }

    if (partDraws == Widget.PartDraws.right || partDraws == Widget.PartDraws.all) {
        renderStatefulTextureQuad(
            parts[ChainPart.right],
            measure.measureParts[ChainPart.right],
            theme.shaders.textureAtlasShader,
            state
        );
    }

    renderStatefulTextureQuad(
        parts[ChainPart.center],
        measure.measureParts[ChainPart.center],
        theme.shaders.textureAtlasShader,
        state
    );
}

QuadMeasure measureStatefulTextureQuad(
    in CameraView cameraView,
    in vec2 position,
    in vec2 size
) {
    QuadMeasure measure;

    measure.transform.position = toScreenPosition(cameraView.viewportHeight, position, size);
    measure.transform.scaling = size;
    measure.modelMatrix = create2DModelMatrix(measure.transform);
    measure.mvpMatrix = cameraView.mvpMatrix * measure.modelMatrix;

    return measure;
}

void renderStatefulTextureQuad(
    in StatefulTextureQuad quad,
    in QuadMeasure measure,
    in ShaderProgram shader,
    in State state
) {
    bindShaderProgram(shader);

    const texCoord = quad.normilizedTexCoords[state];

    setShaderProgramUniformMatrix(shader, "MVP", measure.mvpMatrix);
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

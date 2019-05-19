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
import gapi.font;
import gapi.text;

import rpui.events;
import rpui.theme;
import rpui.widget;
import rpui.render_objects;
import rpui.basic_types;

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

    auto leftSize = vec2(parts[ChainPart.left].texCoords[state].size.x, size.y);
    auto rightSize = vec2(parts[ChainPart.right].texCoords[state].size.x, size.y);
    auto centerSize = vec2(size.x - leftSize.x - rightSize.x, size.y);

    auto leftPos = position;
    auto centerPos = leftPos + vec2(leftSize.x, 0);
    auto rightPos = centerPos + vec2(centerSize.x, 0);

    switch (partDraws) {
        case Widget.PartDraws.left:
            centerSize.x += rightSize.x;
            break;

        case Widget.PartDraws.center:
            centerPos = position;
            centerSize = size;
            break;

        case Widget.PartDraws.right:
            centerPos = leftPos;
            centerSize.x += leftSize.x;
            break;

        default:
            // Nothing
    }

    measure.measureParts[ChainPart.left] = measureStatefulTextureQuad(cameraView, leftPos, leftSize);
    measure.measureParts[ChainPart.center] = measureStatefulTextureQuad(cameraView, centerPos, centerSize);
    measure.measureParts[ChainPart.right] = measureStatefulTextureQuad(cameraView, rightPos, rightSize);

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

    measure.transform.position = toScreenPosition(cameraView.viewportHeight, position, size.y);
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

vec2 toScreenPosition(in float windowHeight, in vec2 position, in float height) {
    return vec2(floor(position.x), floor(windowHeight - height - position.y));
}

void renderUiText(in UiText text, in UiTextMeasure measure, in Theme theme) {
    bindShaderProgram(theme.shaders.textShader);

    setShaderProgramUniformVec4f(theme.shaders.textShader, "color", text.color);
    setShaderProgramUniformTexture(theme.shaders.textShader, "texture", text.texture, 0);
    setShaderProgramUniformMatrix(theme.shaders.textShader, "MVP", measure.mvpMatrix);

    bindVAO(text.geometry.vao);
    bindIndices(text.geometry.indicesBuffer);

    renderIndexedGeometry(cast(uint) quadIndices.length, GL_TRIANGLE_STRIP);
}

UiTextMeasure measureUiTextFixedSize(
    UiText* uiText,
    Font* font,
    in int fontSize,
    in dstring caption,
    in CameraView cameraView,
    in vec2 position,
    in vec2 size,
    in Align textAlign = Align.center,
    in VerticalAlign textVerticalAlign = VerticalAlign.middle
) {
    UiTextMeasure measure;

    UpdateTextInput updateTextInput = {
        textSize: fontSize,
        font: font,
        text: caption
    };

    const textUpdateResult = updateTextureText(&uiText.text, updateTextInput);
    vec2 textPosition = position + uiText.offset;

    uiText.texture = textUpdateResult.texture;
    measure.size = textUpdateResult.surfaceSize;

    const textSize = measure.size;

    // TODO: Move to separate function
    switch (textAlign) {
        case Align.center:
            textPosition.x += round((size.x - textSize.x) * 0.5);
            break;

        case Align.right:
            textPosition.x += size.x - textSize.x;
            break;

        default:
            break;
    }

    switch (textVerticalAlign) {
        case VerticalAlign.bottom:
            textPosition.y += size.y - textSize.y;
            break;

        case VerticalAlign.middle:
            textPosition.y += round((size.y - textSize.y) * 0.5);
            break;

        default:
            break;
    }

    const Transform2D textTransform = {
        position: toScreenPosition(cameraView.viewportHeight, textPosition, textUpdateResult.surfaceSize.y),
        scaling: textUpdateResult.surfaceSize
    };

    measure.mvpMatrix = cameraView.mvpMatrix * create2DModelMatrix(textTransform);

    return measure;
}

UiTextMeasure measureUiText(
    UiText* uiText,
    Font* font,
    in int fontSize,
    in dstring caption,
    in CameraView cameraView,
    in vec2 position
) {
    UiTextMeasure measure;

    UpdateTextInput updateTextInput = {
        textSize: fontSize,
        font: font,
        text: caption
    };

    const textUpdateResult = updateTextureText(&uiText.text, updateTextInput);

    const Transform2D textTransform = {
        position: toScreenPosition(cameraView.viewportHeight, position, textUpdateResult.surfaceSize.y),
        scaling: textUpdateResult.surfaceSize
    };

    measure.mvpMatrix = cameraView.mvpMatrix * create2DModelMatrix(textTransform);
    measure.size = textUpdateResult.surfaceSize;
    uiText.texture = textUpdateResult.texture;

    return measure;
}

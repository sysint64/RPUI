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

interface Renderer {
    void onCreate(Widget widget);

    void onRender();

    void onProgress();
}

void renderTexAtlasQuad(
    in Theme theme,
    in Geometry geometry,
    in Texture2D texture,
    in Texture2DCoords texCoord,
    in QuadTransforms transforms
) {
    const shader = theme.shaders.textureAtlasShader;
    bindShaderProgram(shader);

    setShaderProgramUniformMatrix(shader, "MVP", transforms.mvpMatrix);
    setShaderProgramUniformTexture(shader, "texture", texture, 0);
    setShaderProgramUniformVec2f(shader,"texOffset", texCoord.offset);
    setShaderProgramUniformVec2f(shader,"texSize", texCoord.size);
    setShaderProgramUniformFloat(shader, "alpha", 1.0f);

    bindVAO(geometry.vao);
    bindIndices(geometry.indicesBuffer);
    renderIndexedGeometry(cast(uint) quadIndices.length, GL_TRIANGLE_STRIP);
}

void renderColorQuad(
    in Theme theme,
    in Geometry geometry,
    in vec4 color,
    in QuadTransforms transforms
) {
    const shader = theme.shaders.colorShader;
    bindShaderProgram(shader);

    setShaderProgramUniformMatrix(shader, "MVP", transforms.mvpMatrix);
    setShaderProgramUniformVec4f(shader, "color", color);

    bindVAO(geometry.vao);
    bindIndices(geometry.indicesBuffer);
    renderIndexedGeometry(cast(uint) quadIndices.length, GL_TRIANGLE_STRIP);
}

void renderHorizontalChain(
    in Theme theme,
    in TextureQuad[ChainPart] parts,
    in Texture2DCoords[ChainPart] texCoords,
    in HorizontalChainTransforms transforms,
    in Widget.PartDraws partDraws
) {
    if (partDraws == Widget.PartDraws.left || partDraws == Widget.PartDraws.all) {
        renderTexAtlasQuad(
            theme,
            parts[ChainPart.left].geometry,
            parts[ChainPart.left].texture,
            texCoords[ChainPart.left],
            transforms.quadTransforms[ChainPart.left]
        );
    }

    if (partDraws == Widget.PartDraws.right || partDraws == Widget.PartDraws.all) {
        renderTexAtlasQuad(
            theme,
            parts[ChainPart.right].geometry,
            parts[ChainPart.right].texture,
            texCoords[ChainPart.right],
            transforms.quadTransforms[ChainPart.right]
        );
    }

    renderTexAtlasQuad(
        theme,
        parts[ChainPart.center].geometry,
        parts[ChainPart.center].texture,
        texCoords[ChainPart.center],
        transforms.quadTransforms[ChainPart.center]
    );
}

void renderVerticalChain(
    in Theme theme,
    in TextureQuad[ChainPart] parts,
    in Texture2DCoords[ChainPart] texCoords,
    in HorizontalChainTransforms transforms
) {
    renderTexAtlasQuad(
        theme,
        parts[ChainPart.top].geometry,
        parts[ChainPart.top].texture,
        texCoords[ChainPart.top],
        transforms.quadTransforms[ChainPart.top]
    );

    renderTexAtlasQuad(
        theme,
        parts[ChainPart.bottom].geometry,
        parts[ChainPart.bottom].texture,
        texCoords[ChainPart.bottom],
        transforms.quadTransforms[ChainPart.bottom]
    );

    renderTexAtlasQuad(
        theme,
        parts[ChainPart.middle].geometry,
        parts[ChainPart.middle].texture,
        texCoords[ChainPart.middle],
        transforms.quadTransforms[ChainPart.middle]
    );
}

void renderUiText(
    in Theme theme,
    in UiTextRender text,
    in UiTextAttributes attrs,
    in UiTextTransforms transforms
) {
    bindShaderProgram(theme.shaders.textShader);

    setShaderProgramUniformVec4f(theme.shaders.textShader, "color", attrs.color);
    setShaderProgramUniformTexture(theme.shaders.textShader, "texture", text.texture, 0);
    setShaderProgramUniformMatrix(theme.shaders.textShader, "MVP", transforms.mvpMatrix);

    bindVAO(text.geometry.vao);
    bindIndices(text.geometry.indicesBuffer);

    renderIndexedGeometry(cast(uint) quadIndices.length, GL_TRIANGLE_STRIP);
}

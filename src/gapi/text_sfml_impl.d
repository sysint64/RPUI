module gapi.text_sfml_impl;

import std.conv;
import std.string;
import std.math;

import opengl;
import derelict.sfml2.graphics;

import math.linalg;

import gapi.camera;
import gapi.font;
import gapi.text;
import gapi.texture;
import gapi.text_impl;
import gapi.shader;
import resources.shaders;

class TextSFMLImpl : TextImpl {
    private Shader shader;
    private sfText* sfmlText;
    private sfFont* sfmlFont;
    private Text textObject;

    this() {
        auto shadersRes = new ShadersRes();
        shader = shadersRes.addShader("colorize", "colorize.glsl");
        sfmlText = sfText_create();
    }

    void render(Text textObject, Camera camera) {
        this.textObject = textObject;
        sfmlFont = textObject.font.handles.sfmlHandle;

        sfText_setFont(sfmlText, sfmlFont);
        sfText_setCharacterSize(sfmlText, textObject.textSize);

        string text_s = to!string(textObject.text);
        const char* text_z = toStringz(text_s);

        sfText_setString(sfmlText, text_z);

        const textSize = textObject.textSize;
        const lastPos = textObject.position;
        const lastScale = textObject.scaling;

        const float posX = floor(textObject.getTextRelativePosition().x + textObject.position.x);
        const float posY = floor(textObject.getTextRelativePosition().y + textObject.position.y);

        vec2 glyphPosition = vec2(posX, posY);
        uint prevChar = 0;

        shader.bind();
        textObject.geometry.bind();

        for (size_t i = 0; i < textObject.text.length; ++i) {
            const curChar = textObject.text[i];
            const glyph = sfFont_getGlyph(sfmlFont, curChar, textSize, 0, 0);
            const offset = getCharOffset(prevChar, curChar, glyph);

            glyphPosition.x += offset.x;
            glyphPosition.y = posY + offset.y;

            prevChar = curChar;

            // Rendering
            textObject.position = glyphPosition;
            textObject.scaling = vec2(glyph.bounds.width, glyph.bounds.height);

            Texture.Coord texCoord;

            texCoord.offset = vec2(glyph.textureRect.left, glyph.textureRect.top);

            if (textObject.font.antiAliasing == Font.AntiAliasing.stretchAA) {
                texCoord.size = vec2(glyph.textureRect.width + 0.375f, glyph.textureRect.height);
            } else {
                texCoord.size = vec2(glyph.textureRect.width, glyph.textureRect.height);
            }

            Texture texture = textObject.font.getTexture(textSize);
            texCoord.normalize(texture);

            textObject.updateMatrices(camera);

            shader.setUniformMatrix("MVP", textObject.lastMVPMatrix);
            shader.setUniformTexture("texture", texture);
            shader.setUniformVec2f("texOffset", texCoord.normOffset);
            shader.setUniformVec2f("texSize", texCoord.normSize);
            shader.setUniformVec4f("color", textObject.color);

            textObject.geometry.render();

            glyphPosition.x += glyph.advance;
        }

        textObject.position = lastPos;
        textObject.scaling = lastScale;
    }

    private uint getLineHeight(Text textObject) {
        sfFont* sfmlFont = textObject.font.handles.sfmlHandle;
        return sfFont_getLineSpacing(sfmlFont, textObject.textSize).to!uint;
    }

    private vec2 getCharOffset(in dchar prevChar, in dchar curChar, in sfGlyph glyph) {
        const kerning = sfFont_getKerning(sfmlFont, prevChar, curChar, textObject.textSize);

        vec2 glyphOffset;

        glyphOffset.x = kerning;
        glyphOffset.x += glyph.bounds.left;
        glyphOffset.y = -glyph.bounds.top - glyph.bounds.height;

        return glyphOffset;
    }

    size_t charIndexUnderPoint(Text textObject, in uint x, in uint y) {
        return 0;
    }

    vec2 charPositionUnderPoint(Text textObject, in uint x, in uint y) {
        return vec2(0, 0);
    }

    uint getWidth(Text textObject) {
        return getRegionTextWidth(textObject, 0, textObject.text.length);
    }

    uint getRegionTextWidth(Text textObject, in size_t start, in size_t end) {
        sfFont* sfmlFont = textObject.font.handles.sfmlHandle;
        float width = 0;
        uint prevChar = 0;

        for (size_t i = 0; i < textObject.text.length; ++i) {
            const curChar = textObject.text[i];
            const glyph = sfFont_getGlyph(sfmlFont, curChar, textObject.textSize, 0, 0);
            const kerning = sfFont_getKerning(sfmlFont, prevChar, curChar, textObject.textSize);

            if (i >= start && i < end)
                width += glyph.advance + kerning + glyph.bounds.left;

            prevChar = curChar;
        }

        return width.to!uint;
    }
}

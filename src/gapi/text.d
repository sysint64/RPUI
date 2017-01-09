module gapi.text;

import gapi.font;
import gapi.camera;
import gapi.texture;
import gapi.geometry;
import gapi.shader;
import gapi.base_object;

import math.linalg;

import std.conv;
import std.stdio;

import derelict.sfml2.graphics;


class Text: BaseObject {
    this(Geometry geometry) {
        super(geometry);
    }

    this(Geometry geometry, Font font) {
        super(geometry);
        this.p_font = font;
    }

    this(Geometry geometry, Shader shader, Font font, dstring text) {
        super(geometry);
        this.p_font = font;
        this.p_text = text;
        this.shader = shader;
    }

    vec2 findCharacterPos(in size_t index) {
        sfGlyph glyph = sfFont_getGlyph(font.handle, to!uint(' '), textSize, bold);
        float hspace = glyph.advance;
        vec2 position = vec2(30.0f, 30.0f);

        uint prevChar = 0;

        for (size_t i = 0; i < index; ++i) {
            uint curChar = text[i];
            position.x += font.getKerning(prevChar, curChar, textSize);
            prevChar = curChar;

            glyph = sfFont_getGlyph(font.handle, curChar, textSize, bold);
            position.x += glyph.advance;
        }

        return position;
    }

    override void render(Camera camera) {
        debug assert(font !is null);
        // Texture texture = font.getTexture(p_textSize);
        vec2 lastPosition = position;

        if (!visible)
            return;

        // writeln(texture.width);
        // writeln(texture.height);
        float offset = 0;
        int index = 0;

        sfGlyph glyph = sfFont_getGlyph(font.handle, to!uint(' '), textSize, bold);
        float hspace = glyph.advance;

        uint prevChar = 0;

        for (size_t i = 0; i < text.length; ++i) {
            uint curChar = text[i];

            position = lastPosition;
            offset += font.getKerning(prevChar, curChar, textSize);
            // writeln(prevChar, ",", curChar);
            prevChar = curChar;
            // writeln(font.getKerning(prevChar, curChar, textSize));

            glyph = sfFont_getGlyph(font.handle, curChar, textSize, bold);
            offset += glyph.advance * 0.95f;

            scaling = vec2(glyph.bounds.width, glyph.bounds.height);

            position.x += offset;
            // position += vec2( glyph.bounds.left-to!float(glyph.bounds.width )/2.0f,
            //                  -glyph.bounds.top -to!float(glyph.bounds.height)/2.0f);

            position += vec2( glyph.bounds.left-to!float(glyph.bounds.width),
                             -glyph.bounds.top-to!float(glyph.bounds.height));

            // vec4 texCoord = vec4(to!float(glyph.textureRect.left) / to!float(texture.width),
            //                      to!float(glyph.textureRect.top) / to!float(texture.height),
            //                      to!float(glyph.textureRect.width) / to!float(texture.width),
            //                      to!float(glyph.textureRect.height) / to!float(texture.height));
            // vec4 texCoord = vec4(to!float(glyph.textureRect.left),
            //                      to!float(glyph.textureRect.top),
            //                      to!float(glyph.textureRect.width),
            //                      to!float(glyph.textureRect.height));

            vec4 texCoord;

            texCoord.x = to!float(glyph.textureRect.left);
            texCoord.y = to!float(glyph.textureRect.top);
            texCoord.z = to!float(glyph.textureRect.width);
            texCoord.w = to!float(glyph.textureRect.height);

            // writeln(glyph.textureRect);
            // writeln(glyph.bounds);

            updateMatrices(camera);
            shader.setUniformMatrix("MVP", lastMVPMatrix);
            shader.setUniformVec4f("texCoord", texCoord);
            geometry.render();
            // writeln(glyph.bounds);
            // geometry.
        }

        position = lastPosition;
        // writeln("------------");
    }

    size_t charIndexUnderPoint(in uint x, in uint y) {
        return 0;
    }

    @property Font font() { return p_font; }
    @property uint textSize() { return p_textSize; }
    @property dstring text() { return p_text; }
    @property bool bold() { return p_bold; }

private:
    Font p_font;
    uint p_textSize = 32;
    bool p_bold = false;
    dstring p_text = "";
    Shader shader;
}

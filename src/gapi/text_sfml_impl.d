module gapi.text_sfml_impl;

import std.conv;

import opengl;
import derelict.sfml2.graphics;

import math.linalg;

import gapi.camera;
import gapi.font;
import gapi.text;
import gapi.text_impl;

class TextSFMLImpl: TextImpl {
    void render(Text textObject, Camera camera) {
        sfFont* sfmlFont = textObject.font.handles.sfmlHandle;
        uint textSize = 32;
        bool bold = false;

        vec2 glyphPosition = textObject.position;
        float offset = 0;
        int index = 0;

        sfGlyph glyph = sfFont_getGlyph(sfmlFont, to!uint(' '), textSize, 0, 1);
        float hspace = glyph.advance;

        uint prevChar = 0;

        for (size_t i = 0; i < textObject.text.length; ++i) {
            uint curChar = textObject.text[i];
            offset += sfFont_getKerning(sfmlFont, prevChar, curChar, textSize);
            prevChar = curChar;

            glyph = sfFont_getGlyph(sfmlFont, curChar, textSize, 0, 1);
            offset += glyph.advance;

            textObject.scaling = vec2(glyph.bounds.width, glyph.bounds.height);
            glyphPosition.x += offset;

            glyphPosition += vec2( glyph.bounds.left-to!float(glyph.bounds.width),
                                  -glyph.bounds.top -to!float(glyph.bounds.height));

            vec4 texCoord;

            texCoord.x = to!float(glyph.textureRect.left);
            texCoord.y = to!float(glyph.textureRect.top);
            texCoord.z = to!float(glyph.textureRect.width);
            texCoord.w = to!float(glyph.textureRect.height);

            textObject.updateMatrices(camera);
            // shader.setUniformMatrix("MVP", lastMVPMatrix);
            // shader.setUniformVec4f("texCoord", texCoord);
            textObject.geometry.render();
        }
    }

    size_t charIndexUnderPoint(Text textObject, in uint x, in uint y) {
        return 0;
    }

    vec2 charPositionUnderPoint(Text textObject, in uint x, in uint y) {
        return vec2(0, 0);
    }

    uint getWidth(Text textObject) {
        return 0;
    }

    uint getRegionTextWidth(Text textObject, in size_t start, in size_t end) {
        return 0;
    }
}

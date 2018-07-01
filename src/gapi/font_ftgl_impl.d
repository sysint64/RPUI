module gapi.font_ftgl_impl;

import std.string;

import ftgl;
import derelict.freetype.ft;

import gapi.font;
import gapi.text;
import gapi.font_impl;
import gapi.texture;

class FontFTGLImpl : FontImpl {
    void createFontFromFile(in string fileName) {
        const char* fileNamez = toStringz(fileName);
        this.createdFtglFont = ftglCreateTextureFont(fileNamez);

        ftglSetFontCharMap(createdFtglFont, FT_ENCODING_UNICODE);
    }

    bool createFont(ref FontHandles handles, in string fileName) {
        this.fileName = fileName;

        createFontFromFile(fileName);
        handles.ftglHandle = createdFtglFont;

        return handles.ftglHandle !is null;
    }

    void destroyFont(ref FontHandles handles) {
    }

    void setTextSize(Font font, in uint textSize) {
        if ((textSize in ftglFonts) !is null) {
            return;
        } else {
            createFontFromFile(fileName);
        }

        ftglFonts[textSize] = createdFtglFont;
        ftglSetFontFaceSize(ftglFonts[textSize], textSize, textSize);
        createdFtglFont = null;
    }

    Texture getTexture(Font font) {
        return null;
    }

    void bind(ref FontHandles handles, Text text) {
        handles.ftglHandle = ftglFonts[text.textSize];
    }

    void update(Font font) {
    }

private:
    FTGLfont* createdFtglFont = null;
    FTGLfont*[uint] ftglFonts;
    string fileName;
}

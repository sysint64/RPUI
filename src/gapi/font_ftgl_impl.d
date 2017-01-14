module gapi.font_ftgl_impl;

import std.string;

import ftgl;
import derelict.freetype.ft;

import gapi.font;
import gapi.font_impl;
import gapi.texture;


class FontFTGLImpl : FontImpl {
    bool createFont(ref FontHandles handles, in string fileName) {
        const char* fileNamez = toStringz(fileName);
        FTGLfont* font = ftglCreateTextureFont(fileNamez);
        ftglSetFontCharMap(font, FT_ENCODING_UNICODE);
        handles.ftglHandle = font;

        return handles.ftglHandle !is null;
    }

    void destroyFont(ref FontHandles handles) {
    }

    void setTextSize(Font font, in uint textSize) {
        FTGLfont* ftglFont = font.handles.ftglHandle;
        ftglSetFontFaceSize(ftglFont, textSize, textSize);
    }

    Texture getTexture(Font font) {
        return null;
    }
}

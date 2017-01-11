module gapi.font_ftgl_impl;

import std.string;

import ftgl;

import gapi.font_impl;
import gapi.texture;


class FontFTGLImpl : FontImpl {
    FontHandles createFont(in string fileName) {
        const char* fileNamez = toStringz(fileName);
        FTGLfont* font = ftglCreateTextureFont(fileNamez);

        FontHandles handles;
        handles.ftglHandle = font;

        return handles;
    }

    void setTextSize(in uint textSize) {
    }

    Texture getTexture() {
        return null;
    }
}

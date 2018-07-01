module gapi.font_sfml_impl;

import std.string;

import derelict.sfml2.graphics;

import gapi.font;
import gapi.text;
import gapi.font_impl;
import gapi.texture;

final class FontSFMLImpl : FontImpl {
    bool createFont(ref FontHandles handles, in string fileName) {
        const char* fileNamez = toStringz(fileName);
        handles.sfmlHandle = sfFont_createFromFile(fileNamez);

        return handles.sfmlHandle !is null;
    }

    void destroyFont(ref FontHandles handles) {
        sfFont_destroy(handles.sfmlHandle);
    }

    void setTextSize(Font font, in uint textSize) {
        characterSize = textSize;
    }

    Texture getTexture(Font font) {
        sfFont* sfmlFont = font.handles.sfmlHandle;

        if ((characterSize in texture) is null) {
            const(sfTexture)* sf_texture = sfFont_getTexture(sfmlFont, characterSize);
            texture[characterSize] = new Texture(sf_texture);
            texture[characterSize].smooth = true;
        }

        return texture[characterSize];
    }

    void bind(ref FontHandles handles, Text text) {
    }

    void update(Font font) {
        sfFont* sfmlFont = font.handles.sfmlHandle;
        auto texture = getTexture(font);

        const(sfTexture)* sf_texture = sfFont_getTexture(sfmlFont, characterSize);
        texture.sf_texture = sf_texture;
    }

private:
    Texture[uint] texture;
    uint characterSize;
}

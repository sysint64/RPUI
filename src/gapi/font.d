module gapi.font;

import std.string;
import std.conv;
import derelict.sfml2.graphics;
import ftgl;

import gapi.font_impl;
import gapi.font_ftgl_impl;
import gapi.texture;


class Font {
    this(in string fileName) {
        version (FTGLFont) {
            impl = new FontFTGLImpl();
        }

        if (!impl.createFont(handles, fileName)) {
            throw new Error("Can't load font '" ~ fileName ~ "'");
        }
        // const char* fileNamez = toStringz(fileName);
        // handle = sfFont_createFromFile(fileNamez);

        // if (!handle) {
        //     throw new Error("Can't load font '" ~ fileName ~ "'");
        // }
    }

    ~this() {
        // sfFont_destroy(handle);
    }

    Texture getTexture(in uint characterSize) {
        return impl.getTexture(this);
        // if ((characterSize in texture) is null) {
        //     const(sfTexture)* sf_texture = sfFont_getTexture(handle, characterSize);
        //     texture[characterSize] = new Texture(sf_texture);
        // } else {
        //     const(sfTexture)* sf_texture = sfFont_getTexture(handle, characterSize);
        //     texture[characterSize].sf_texture = sf_texture;
        // }

        // return texture[characterSize];
    }

    void setTextSize(in uint textSize) {
        impl.setTextSize(this, textSize);
    }

package:
    FontImpl impl;
    // sfFont* handle;
    FontHandles handles;
    // FTGLfont* ftglFont;
    // Texture[uint] texture;
    // Texture texture;
}

module gapi.font;

import std.string;
import std.conv;
import derelict.sfml2.graphics;

import gapi.texture;


class Font {
    this(in string fileName) {
        const char* fileNamez = toStringz(fileName);
        handle = sfFont_createFromFile(fileNamez);

        if (!handle) {
            throw new Error("Can't load font '" ~ fileName ~ "'");
        }
    }

    ~this() {
        sfFont_destroy(handle);
    }

    Texture getTexture(in uint characterSize) {
        if ((characterSize in texture) is null) {
            const(sfTexture)* sf_texture = sfFont_getTexture(handle, characterSize);
            texture[characterSize] = new Texture(sf_texture);
        } else {
            const(sfTexture)* sf_texture = sfFont_getTexture(handle, characterSize);
            texture[characterSize].sf_texture = sf_texture;
        }

        return texture[characterSize];
        // const(sfTexture)* sf_texture = sfFont_getTexture(handle, characterSize);
        // return new Texture(sf_texture);
    }

    float getKerning(in uint prevChar, in uint curChar, in uint textSize) {
        return sfFont_getKerning(handle, prevChar, curChar, textSize);
    }

package:
    sfFont* handle;
    Texture[uint] texture;
    // Texture texture;
}

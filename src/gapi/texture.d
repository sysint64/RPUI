module gapi.texture;

import std.string;
import std.stdio;
import std.conv;
import derelict.sfml2.graphics;


class Texture {
    this(in string fileName) {
        const char* fileNamez = toStringz(fileName);
        texture = sfTexture_createFromFile(fileNamez, null);

        if (!texture) {
            // Error
        }
    }

    ~this() {
        sfTexture_destroy(texture);
    }

    void bind() {
        sfTexture_bind(texture);
    }

    void unbind() {
        sfTexture_bind(null);
    }

    @property bool repeated() {
        return to!bool(sfTexture_isRepeated(texture));
    }

    @property void repeated(bool val) {
        sfTexture_setRepeated(texture, to!int(val));
    }

    @property bool smooth() {
        return to!bool(sfTexture_isSmooth(texture));
    }

    @property void smooth(bool val) {
        sfTexture_setSmooth(texture, to!int(val));
    }

    @property uint width() {
        return sfTexture_getSize(texture).x;
    }

    @property uint height() {
        return sfTexture_getSize(texture).y;
    }

private:
    sfTexture* texture;
}

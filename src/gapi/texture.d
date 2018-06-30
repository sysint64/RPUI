module gapi.texture;

import std.string;
import std.stdio;
import std.conv;
import std.exception;

import derelict.sfml2.graphics;
import opengl;

import math.linalg;

class Texture {
    struct Coord {
        vec2 offset;
        vec2 size;
        vec2 normOffset;
        vec2 normSize;
        bool isNormalized = false;

        void normalize(Texture texture) {
            normOffset = vec2(offset.x / texture.width, offset.y / texture.height);
            normSize = vec2(size.x / texture.width, size.y / texture.height);
            isNormalized = true;
        }

        static Coord normalize(in Coord coord, Texture texture) {
            Coord normCoord = coord;
            normCoord.normalize(texture);
            return normCoord;
        }

    private:
        float normX, normY;
        float normWidth, normHeight;
    }

    bool smooth = false;
    bool repeated = false;

    this(in string fileName) {
        const char* fileNamez = toStringz(fileName);
        sf_texture = sfTexture_createFromFile(fileNamez, null);

        if (!sf_texture) {
            throw new Error("Can't load image '" ~ fileName ~ "'");
        }
    }

    ~this() {
        if (sf_texture is null) {
            glDeleteTextures(1, &p_handle);
            sfImage_destroy(image);
        }
    }

    void bind() {
        if (sf_texture !is null) {
            sfTexture_bind(sf_texture);
        } else {
            glBindTexture(GL_TEXTURE_2D, p_handle);
        }

        GLuint wrap = repeated ? GL_REPEAT : GL_CLAMP_TO_EDGE;
        GLuint filter = smooth ? GL_LINEAR : GL_NEAREST;

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, filter);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, filter);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, wrap);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, wrap);
    }

    void unbind() {
        glBindTexture(GL_TEXTURE_2D, 0);
    }

    void update() {
        const(ubyte)* data = sfImage_getPixelsPtr(image);
        glBindTexture(GL_TEXTURE_2D, p_handle);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
    }

    void saveToFile(in string fileName) {
        const char* fileNamez = toStringz(fileName);
        sfImage* image = sfTexture_copyToImage(sf_texture);
        sfImage_saveToFile(image, fileNamez);
    }

    @property GLuint handle() { return p_handle; }
    @property uint width() {
        if (sf_texture !is null) {
            return sfTexture_getSize(sf_texture).x;
        } else {
            return sfImage_getSize(image).x;
        }
    }

    @property uint height() {
        if (sf_texture !is null) {
            return sfTexture_getSize(sf_texture).y;
        } else {
            return sfImage_getSize(image).y;
        }
    }

package:
    const(sfTexture)* sf_texture;

    this(const(sfTexture)* sf_texture) {
        this.sf_texture = sf_texture;
    }

private:
    sfImage* image;
    GLuint p_handle;
}

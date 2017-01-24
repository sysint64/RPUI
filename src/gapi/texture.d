module gapi.texture;

import std.string;
import std.stdio;
import std.conv;
import std.exception;

import derelict.sfml2.graphics;
import derelict.opengl3.gl;

import math.linalg;


class Texture {
    struct Coord {
        vec2 offset;
        vec2 size;
        bool normalized = false;

        Coord getNrom(Texture texture) {
            Coord coord;

            coord.offset = vec2(offset.x / texture.width, offset.y / texture.height);
            coord.size = vec2(size.x / texture.width, size.y / texture.height);
            coord.normalized = true;

            return coord;
        }

    private:
        float normX, normY;
        float normWidth, normHeight;
    };

    // this(in string fileName) {
    //     const char* fileNamez = toStringz(fileName);
    //     image = sfImage_createFromFile(fileNamez);

    //     if (!image) {
    //         throw new Error("Can't load image '" ~ fileName ~ "'");
    //     }

    //     glGenTextures(1, &p_handle);
    //     update();
    // }

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
    }

    void unbind() {
        glBindTexture(GL_TEXTURE_2D, 0);
    }

    void update() {
        const(ubyte)* data = sfImage_getPixelsPtr(image);
        glBindTexture(GL_TEXTURE_2D, p_handle);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);

        GLuint wrap = repeated ? GL_REPEAT : GL_CLAMP_TO_EDGE;
        GLuint filter = smooth ? GL_LINEAR : GL_NEAREST;

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, filter);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, filter);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, wrap);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, wrap);
    }

    void saveToFile(in string fileName) {
        const char* fileNamez = toStringz(fileName);
        sfImage* image = sfTexture_copyToImage(sf_texture);
        sfImage_saveToFile(image, fileNamez);
    }

    @property GLuint handle() { return p_handle; }
    @property ref bool repeated() { return p_repeated; }
    @property void repeated(bool val) {
        p_repeated = val;
        update();
    }

    @property ref bool smooth() { return p_smooth; }
    @property void smooth(bool val) {
        p_smooth = val;
        update();
    }

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

    bool p_smooth = false;
    bool p_repeated = false;
}


module gapi.texture;

import std.string;
import std.stdio;
import std.conv;
import std.exception;

import derelict.sfml2.graphics;
import derelict.opengl3.gl;


class Texture {
    this(in string fileName) {
        const char* fileNamez = toStringz(fileName);
        image = sfImage_createFromFile(fileNamez);

        if (!image) {
            // Error
            throw new Error("Can't load image '" ~ fileName ~ "'");
        }

        glGenTextures(1, &p_handle);
        update();
    }

    ~this() {
        glDeleteTextures(1, &p_handle);
        sfImage_destroy(image);
    }

    void bind() {
        glBindTexture(GL_TEXTURE_2D, p_handle);
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
        return sfImage_getSize(image).x;
    }

    @property uint height() {
        return sfImage_getSize(image).y;
    }

private:
    sfImage* image;
    GLuint p_handle;

    bool p_smooth = false;
    bool p_repeated = false;
}

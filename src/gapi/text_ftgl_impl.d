module gapi.text_ftgl_impl;

import std.conv;
import std.math;
import std.string;

import derelict.opengl3.gl;

import ftgl;
import application;
import math.linalg;

import gapi.utils;
import gapi.camera;
import gapi.font;
import gapi.text_impl;


class TextFTGLImpl: TextImpl {
    void render(Font font, in dstring text, in vec3 color, in vec2 position, Camera camera) {
        auto app = Application.getInstance();
        auto ftglFont = font.handles.ftglHandle;

        app.unbindLastShader();
        glBegin2D();

        glActiveTexture(GL_TEXTURE0);
        glColor3fv(color.value_ptr);
        glTranslatef(position.x, position.y, 0);

        string text_s = to!string(text);
        const char* text_z = toStringz(text_s);
        ftglRenderFont(ftglFont, text_z, RENDER_ALL);

        glEnd2D();
        app.bindLastShader();
    }

    size_t charIndexUnderPoint(in Font font, in dstring text, in uint x, in uint y) {
        return 0;
    }

    vec2 charPositionUnderPoint(in Font font, in dstring text, in uint x, in uint y) {
        return vec2(0, 0);
    }

    uint getWidth(in Font font, in dstring text) {
        float[6] bounds;
        int n = to!int(text.length);

        FTGLfont* ftglFont;
        ftglGetFontBBox(ftglFont, "Hello World!", n, bounds);

        float width = bounds[3] - bounds[0];
        return to!uint(round(width));
    }
}

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
    void render(in Font font, in dstring text, in vec3 color, in vec2 position, Camera camera) {
        auto app = Application.getInstance();
        FTGLfont* ftglFont;

        glBegin2D();
        glActiveTexture(GL_TEXTURE0);
        glColor3fv(color.value_ptr);
        glTranslatef(position.x, app.windowHeight-position.y, 0);
        ftglRenderFont(ftglFont, "Hello world!", RENDER_ALL);

        glEnd2D();
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

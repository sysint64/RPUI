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
import gapi.text;
import gapi.text_impl;


class TextFTGLImpl: TextImpl {
    void render(Text textObject, Camera camera) {
        auto app = Application.getInstance();
        auto ftglFont = textObject.font.handles.ftglHandle;

        auto lastShader = app.lastShader;

        if (lastShader !is null)
            lastShader.unbind();

        glBegin2D();

        const float posY = textObject.getTextPosition().y;
        const float posX = textObject.getTextPosition().x;

        glActiveTexture(GL_TEXTURE0);
        glColor3fv(textObject.color.value_ptr);
        glTranslatef(posX - 1, posY, 0);

        string text_s = to!string(textObject.text);
        const char* text_z = toStringz(text_s);
        ftglRenderFont(ftglFont, text_z, RENDER_ALL);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

        glEnd2D();

        if (lastShader !is null)
            lastShader.bind();
    }

    size_t charIndexUnderPoint(Text textObject, in uint x, in uint y) {
        return 0;
    }

    vec2 charPositionUnderPoint(Text textObject, in uint x, in uint y) {
        return vec2(0, 0);
    }

    uint getWidth(Text textObject) {
        float[6] bounds;
        const n = to!int(textObject.text.length);

        string text_s = to!string(textObject.text);
        const char* text_z = toStringz(text_s);

        FTGLfont* ftglFont = textObject.font.handles.ftglHandle;
        ftglGetFontBBox(ftglFont, text_z, n, bounds);

        const width = round(bounds[3] - bounds[0]);
        return to!uint(width);
    }
}

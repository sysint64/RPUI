module log;

import std.container;
import std.stdio;
import std.format : formattedWrite;
import std.array : appender;
import std.range : take;

import application;
import math.linalg;

import gapi.text;
import gapi.font;
import gapi.geometry;
import gapi.camera;


void logError(Char, T...)(in Char[] fmt, T args) {
    auto app = Application.getInstance();
    debug app.logError(fmt, args);
}


void logWarning(Char, T...)(in Char[] fmt, T args) {
    debug app.logWarning(fmt, args);
}


void logDebug(Char, T...)(in Char[] fmt, T args) {
    debug app.logDebug(fmt, args);
}


class Log {
    this() {
        font = Font.createFromFile("DejaVuSans.ttf");
    }

    void display(vec4, Char, T...)(in vec4 color, in Char[] fmt, T args) {
        auto writer = appender!dstring();
        formattedWrite(writer, fmt, args);
        LogText text = new LogText(glyphGeometry, font, writer.data, color);
        text.textSize = p_textSize;
        texts.insertBack(text);
    }

    void display(Char, T...)(in Char[] fmt, T args) {
        display(vec4(0, 0, 0, 1), fmt, args);
    }

    void render(Camera camera) {
        uint verticalOffset = padding.y + p_textSize;

        foreach_reverse (LogText text; texts) {
            text.position.x = padding.x;
            text.position.y = app.windowHeight - verticalOffset;
            verticalOffset += text.textSize + 5;
            text.render(camera);
        }

        removeExpired();
    }

    void removeExpired() {
        if (texts.length == 0)
            return;

        if (texts.back.leftTime <= 0.0f)
            texts.removeBack();
    }

private:
    Font font;
    Geometry glyphGeometry;
    Array!LogText texts;
    Application app;
    vec2i padding = vec2i(10, 10);
    uint p_textSize = 18;

    class LogText : Text {
        this(Geometry geometry, Font font, in dstring text, in vec4 color) {
            super(geometry, font);
            leftTime = deadTime;
            app = Application.getInstance();
            this.text = text;
            this.color = color;
        }

        override void render(Camera camera) {
            super.render(camera);
            leftTime -= app.deltaTime;
        }

    private:
        const double deadTime = 10000.0f;
        double leftTime;
    }
}

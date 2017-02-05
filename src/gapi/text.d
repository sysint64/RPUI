module gapi.text;

import gapi.font;
import gapi.camera;
import gapi.texture;
import gapi.geometry;
import gapi.shader;
import gapi.base_object;
import gapi.text_impl;
import gapi.text_ftgl_impl;
import gapi.text_sfml_impl;

import math.linalg;

import std.conv;
import std.stdio;


class Text: BaseObject {
    static class Builder(T: Text) {
        this(Geometry geometry) {
            this.geometry = geometry;
        }

        Builder!T setColor(in vec4 color) {
            this.color = color;
            return this;
        }

        Builder!T setFont(Font font) {
            this.font = font;
            return this;
        }

        Builder!T setTextSize(in uint textSize) {
            this.textSize = textSize;
            return this;
        }

        T build() {
            T text = new T(geometry);
            text.font = font;
            text.color = color;
            text.textSize = textSize;
            return text;
        }

    private:
        Geometry geometry;
        vec4 color = vec4(0, 0, 0, 1);
        uint textSize = 12;
        Font font;
    }

    this(Geometry geometry) {
        super(geometry);
        createImpl();
    }

    this(Geometry geometry, Font font) {
        super(geometry);
        this.p_font = font;
        createImpl();
        font.setTextSize(textSize);
    }

    this(Geometry geometry, Font font, in dstring text) {
        super(geometry);
        this.p_font = font;
        this.p_text = text;
        createImpl();
        font.setTextSize(textSize);
    }

    this(Geometry geometry, Font font, in vec4 color) {
        super(geometry);
        this.p_font = font;
        this.p_color = color;
        createImpl();
        font.setTextSize(textSize);
    }

    this(Geometry geometry, Font font, in dstring text, in vec4 color) {
        super(geometry);
        this.p_font = font;
        this.p_text = text;
        this.p_color = color;
        createImpl();
        font.setTextSize(textSize);
    }

    override void render(Camera camera) {
        debug assert(font !is null);
        debug assert(impl !is null);

        if (!visible)
            return;

        font.bind(this);
        impl.render(this, camera);
    }

    size_t charIndexUnderPoint(in uint x, in uint y) {
        return 0;
    }

    @property Font font() { return p_font; }
    @property void font(Font val) { p_font = val; }

    @property ref uint textSize() { return p_textSize; }
    @property void textSize(in uint val) {
        p_textSize = val;
        font.setTextSize(p_textSize);
    }

    @property ref dstring text() { return p_text; }
    @property void text(in dstring val) { p_text = val; }
    @property bool bold() { return p_bold; }
    @property ref vec4 color() { return p_color; }
    @property void color(in vec4 val) { p_color = val; }

private:
    Font p_font;
    uint p_textSize = 12;
    bool p_bold = false;
    dstring p_text = "";
    vec4 p_color;
    TextImpl impl;

    void createImpl() {
        version (FTGLFont) {
            impl = new TextFTGLImpl();
        } else version(SFMLFont) {
            impl = new TextSFMLImpl();
        }
    }
}

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
    this(Geometry geometry) {
        super(geometry);
        createImpl();
        font.setTextSize(textSize);
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

        impl.render(this, camera);
    }

    size_t charIndexUnderPoint(in uint x, in uint y) {
        return 0;
    }

    @property Font font() { return p_font; }

    @property ref uint textSize() { return p_textSize; }
    @property void textSize(in uint val) {
        p_textSize = val;
        font.setTextSize(p_textSize);
    }

    @property dstring text() { return p_text; }
    @property bool bold() { return p_bold; }
    @property ref vec4 color() { return p_color; }
    @property void color(in vec4 val) { p_color = val; }

private:
    Font p_font;
    uint p_textSize = 18;
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

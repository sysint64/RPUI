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

import basic_types;
import math.linalg;

import std.conv;
import std.stdio;
import std.math;

class Text : BaseObject {
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
        this.font = font;
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

    Font font;

    @property uint textSize() { return p_textSize; }
    @property void textSize(in uint val) {
        p_textSize = val;
        font.setTextSize(p_textSize);
    }

    @property uint textWidth() { return impl.getWidth(this); }

    uint getRegionTextWidth(in size_t start, in size_t end) {
        return impl.getRegionTextWidth(this, start, end);
    }

    utfstring text = "";
    vec4 color;
    Align textAlign = Align.center;
    VerticalAlign textVerticalAlign = VerticalAlign.middle;

    @property bool bold() { return p_bold; }

    // TODO: Remove hardcode
    @property uint lineHeight() { return p_textSize - 4; }

    vec2 getTextRelativePosition() {
        vec2 textPosition = vec2(0, 0);
        const uint textWidth = impl.getWidth(this);

        switch (textAlign) {
            case Align.center:
                textPosition.x += round((scaling.x - textWidth) * 0.5);
                break;

            case Align.right:
                textPosition.x += scaling.x - textWidth;
                break;

            default:
                break;
        }

        switch (textVerticalAlign) {
            case VerticalAlign.bottom:
                textPosition.y += scaling.y - lineHeight;
                break;

            case VerticalAlign.middle:
                textPosition.y += round((scaling.y - lineHeight) * 0.5);
                break;

            default:
                break;
        }

        return textPosition;
    }

private:
    uint p_textSize = 12;
    bool p_bold = false;

    TextImpl impl;

    void createImpl() {
        version (FTGLFont) {
            impl = new TextFTGLImpl();
        } else version(SFMLFont) {
            impl = new TextSFMLImpl();
        }
    }
}

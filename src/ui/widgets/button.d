module ui.widgets.button;

import input;
import gapi;
import math.linalg;
import std.stdio;
import basic_types;
import accessors;

import ui.widget;
import ui.manager;
import ui.render_objects;


class Button : Widget {
    this(in string style) {
        super(style);
        this.drawChildren = false;
    }

    this(bool allowCheck) {
        super();
        this.allowCheck = allowCheck;
        this.drawChildren = false;
    }

    override void render(Camera camera) {
        super.render(camera);
        updateAbsolutePosition();
        renderSkin(camera);
        renderIcon(camera);
    }

    // Properties

    bool allowCheck = false;
    Align textAlign = Align.center;
    VerticalAlign textVerticalAlign = VerticalAlign.middle;

    utfstring caption_ = "Button";
    @property ref utfstring caption() { return caption_; }

protected:
    vec2 focusOffsets;
    float focusResize;

    BaseRenderObject[string] skinRenderObjects;
    BaseRenderObject[string] skinFocusRenderObjects;

    BaseRenderObject icon1RenderObject;
    BaseRenderObject icon2RenderObject;
    TextRenderObject textRenderObject;

    void renderSkin(Camera camera) {
        size_t[3] coordIndices;

        textRenderObject.text = caption;
        textRenderObject.textAlign = textAlign;
        textRenderObject.textVerticalAlign = textVerticalAlign;

        renderer.renderHorizontalChain(skinRenderObjects, state, absolutePosition, size);
        renderer.renderText(textRenderObject, state, absolutePosition, size);

        if (focused) {
            const vec2 focusPos = absolutePosition + focusOffsets;
            const vec2 focusSize = size + vec2(focusResize, focusResize);

            renderer.renderHorizontalChain(skinFocusRenderObjects, "Focus", focusPos, focusSize);
        }
    }

    void renderIcon(Camera camera) {
    }

    override void onCreate() {
        super.onCreate();

        immutable string[3] elements = ["Leave", "Enter", "Click"];
        immutable string[3] keys = ["left", "center", "right"];

        foreach (string key; keys) {
            renderFactory.createQuad(skinRenderObjects, style, elements, key);
            renderFactory.createQuad(skinFocusRenderObjects, style, "Focus", key);
        }

        const string focusKey = style ~ ".Focus";
        with (manager.theme) {
            focusOffsets = data.getVec2f(focusKey ~ ".offsets.0");
            focusResize = data.getNumber(focusKey ~ ".offsets.1");
        }

        textRenderObject = renderFactory.createText(style, elements);
    }
}

module ui.widgets.button;

import input;
import gapi;
import math.linalg;

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
        this.p_allowCheck = allowCheck;
        this.drawChildren = false;
    }

    override void render(Camera camera) {
        super.render(camera);
        updateAbsolutePosition();
        renderSkin();
        renderIcon();
        renderText();
    }

    // Properties
    @property ref bool allowCheck() { return p_allowCheck; }
    @property void allowCheck(in bool val) { p_allowCheck = val; }

    @property ref utfstring caption() { return p_caption; }
    @property void caption(in utfstring val) { p_caption = val; }

    @property Align textAlign() { return p_textAlign; }
    @property void textAlign(in Align val) { p_textAlign = val; }

    @property VerticalAlign textVerticalAlign() { return p_textVerticalAlign; }
    @property void textVerticalAlign(in VerticalAlign val) { p_textVerticalAlign = val; }

protected:
    vec2i focusOffsets;
    uint focusResize;

    string leaveElement = "Leave";
    string enterElement = "Enter";
    string clickElement = "Click";
    string focusElement = "Focus";

    BaseRenderObject[string] skinRenderObjects;
    BaseRenderObject[string] skinFocusRenderObjects;

    BaseRenderObject icon1RenderObject;
    BaseRenderObject icon2RenderObject;
    TextRenderObject textRenderObject;

    bool p_allowCheck = false;
    utfstring p_caption;
    Align p_textAlign = Align.center;
    VerticalAlign p_textVerticalAlign = VerticalAlign.middle;

    void renderSkin() {
        size_t[3] coordIndices;
        string state = leaveElement;

        if (isEnter)
            state = enterElement;

        if (isClick)
            state = clickElement;

        with (renderer) {
            renderPartsHorizontal(skinRenderObjects, state, absolutePosition, size);

            if (focused) {
                const vec2i focusPos = absolutePosition + focusOffsets;
                const vec2i focusSize = size + vec2i(focusResize, focusResize);
                renderPartsHorizontal(skinFocusRenderObjects, focusElement, focusPos, focusSize);
            }
        }
    }

    void renderIcon() {
    }

    void renderText() {

    }

    override void precompute() {
        string[3] elements = [leaveElement, enterElement, clickElement];
        string[3] keys = ["left", "center", "right"];

        foreach (string key; keys) {
            renderFactory.createQuad(skinRenderObjects, style, elements, key);
            renderFactory.createQuad(skinFocusRenderObjects, style, focusElement, key);
        }

        const string focusKey = style ~ "." ~ focusElement;
        with (manager.theme) {
            focusOffsets = data.getVec2i(focusKey ~ ".offsets");
            focusResize = data.getInteger(focusKey ~ ".offsets.2");
        }
    }
}

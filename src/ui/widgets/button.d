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
    }

    this(bool allowCheck) {
        super();
        this.p_allowCheck = allowCheck;
    }

    override void render(Camera camera) {
        if (drawChildren)
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
    // Render part
    enum RenderPartIndex {
        leaveStart = 0, leaveLeft = 0, leaveCenter = 1, leaveRight = 2,
        enterStart = 3, enterLeft = 3, enterCenter = 4, enterRight = 5,
        clickStart = 6, clickLeft = 6, clickCenter = 7, clickRight = 8,
        focusStart = 9, focusLeft = 9, focusCenter = 10, focusRight = 11,
    };

    bool drawChildren = false;
    vec2i focusOffsets;
    uint focusResize;

    string leaveElement = "Leave";
    string enterElement = "Enter";
    string clickElement = "Click";
    string focusElement = "Focus";

    BaseRenderObject[3] skinRenderObjects;
    BaseRenderObject[3] skinFocusRenderObjects;

    BaseRenderObject icon1RenderObject;
    BaseRenderObject icon2RenderObject;
    TextRenderObject textRenderObject;

    bool p_allowCheck = false;
    utfstring p_caption;
    Align p_textAlign = Align.center;
    VerticalAlign p_textVerticalAlign = VerticalAlign.middle;

    void renderSkin() {
        size_t[3] coordIndices;

        with (RenderPartIndex) {
            coordIndices = [leaveLeft, leaveCenter, leaveRight];

            if (isEnter)
                coordIndices = [enterLeft, enterCenter, enterRight];

            if (isClick)
                coordIndices = [clickLeft, clickCenter, clickRight];

            // renderPartsHorizontal(skinRenderObjects, coordIndices, absolutePosition, size);

            // if (focused) {
            //     immutable vec2i focusPos = absolutePosition + focusOffsets;
            //     immutable vec2i focusSize = size + vec2i(focusResize, 0);
            //     coordIndices = [focusLeft, focusCenter, focusRight];
            //     renderPartsHorizontal(skinFocusRenderObjects, coordIndices, focusPos, focusSize);
            // }
        }
    }

    void renderIcon() {
    }

    void renderText() {

    }

    // precomputer
    override void precompute() {
        string[4] elements = [leaveElement, enterElement, clickElement, focusElement];
        skinRenderObjects[0] = renderFactory.createQuad(style, elements, "left");
        // skinRenderObjects[1] = renderFactory.createQuad(style, elements, "center");
        // skinRenderObjects[2] = renderFactory.createQuad(style, elements, "right");
        app.logDebug("Precomputed button");
        // skinRenderObjects[0] = new QuadRenderObject(manager, style, leaveElement, "left");
        // skinRenderObjects[1] = new QuadRenderObject(manager, style, leaveElement, "center");
        // skinRenderObjects[2] = new QuadRenderObject(manager, style, leaveElement, "right");
    }
}

module ui.widgets.panel;

import std.container;

import basic_types;
import math.linalg;
import gapi;

import ui.widget;
import ui.manager;
import ui.render_objects;


class Panel : Widget {
    this(in string style) {
        super(style);
    }

    override void render(Camera camera) {
        split.isEnter = false;
        float lastPaddingTop = padding.top;
	uint scissorHeader = 0;

        updateAbsolutePosition();
	updateScroll();

        if (background != Background.transparent)
            renderer.renderColorQuad(backgroundRenderObject, backgroundColors[background],
                                     absolutePosition, size);

        if (allowResize || showSplit)
            calculateSplit();

        if (allowHide) {
        }

        if (!isOpen) {
            updateAlign();
            padding.top = lastPaddingTop;
            renderSplit();
            return;
        }

        // Render children
        Rect scissor;
        scissor.point = vec2(absolutePosition.x, absolutePosition.y + scissorHeader);
        scissor.size = vec2(size.x, size.y - scissorHeader);
        manager.pushScissor(scissor);

        super.render(camera);

        manager.popScissor();

        renderScroll();
        renderSplit();
	updateAlign();
    }

    override void onCreate() {
        renderFactory.createQuad(backgroundRenderObject);

        with (manager.theme) {
            backgroundColors[Background.light]  = data.getNormColor(style ~ ".backgroundLight");
            backgroundColors[Background.dark]   = data.getNormColor(style ~ ".backgroundDark");
            backgroundColors[Background.action] = data.getNormColor(style ~ ".backgroundAction");
        }
    }

    enum Background {transparent, light, dark, action};

    @property ref bool showVerticalScrollButton() { return p_showVerticalScrollButton; }
    @property ref bool showHorizontalScrollButton() { return p_showHorizontalScrollButton; }
    @property void showVerticalScrollButton(in bool val) { p_showVerticalScrollButton = val; }
    @property void showHorizontalScrollButton(in bool val) { p_showHorizontalScrollButton = val; }

    @property vec2 scrollInPx() {
        return vec2(horizontalScrollButton.offset, verticalScrollButton.offset);
    }

    @property
    void showScrollButtons(in bool val) {
        p_showVerticalScrollButton = val;
        p_showHorizontalScrollButton = val;
    }

    @property ref utfstring caption() { return p_caption; }
    @property void caption(in utfstring val) { p_caption = val; }

    @property Background background() { return p_background; }
    @property void background(in Background val) { p_background = val; }

    @property ref bool allowResize() { return p_allowResize; }
    @property void allowResize(in bool val) { p_allowResize = val; }

    @property ref bool allowHide() { return p_allowHide; }
    @property void allowHide(in bool val) { p_allowHide = val; }

    @property ref bool allowDrag() { return p_allowDrag; }
    @property void allowDrag(in bool val) { p_allowDrag = val; }

    @property ref bool isOpen() { return p_isOpen; }
    @property void isOpen(in bool val) { p_isOpen = val; }

    @property ref bool blackSplit() { return p_blackSplit; }
    @property void blackSplit(in bool val) { p_blackSplit = val; }

    @property ref bool showSplit() { return p_showSplit; }
    @property void showSplit(in bool val) { p_showSplit = val; }

private:
    BaseRenderObject[string] scrollBackgroundRenderObjects;
    BaseRenderObject[string] scrollButtonRenderObjects;
    BaseRenderObject splitRenderObject;
    BaseRenderObject headerRenderObject;
    BaseRenderObject expandArrowRenderObject;
    BaseRenderObject backgroundRenderObject;
    TextRenderObject textRenderObject;

    vec4[Background] backgroundColors;

    vec2 widgetsOffset;

    struct Split {
        bool isEnter = false;
        bool isClick = false;
        vec2 position;
        vec2 size;
    }

    Split split;

    float panelSize;
    float currentPanelSize;

    float headerSize = 0;
    bool headerIsEnter = false;

    struct ScrollButton {
        bool isEnter = false;
        bool isClick = false;
        float size = 0;
        float minPos = 0;
        float maxPos = 0;
        float offset;
        float lastOffset;
    }

    ScrollButton verticalScrollButton;
    ScrollButton horizontalScrollButton;

    Array!Widget joinedWidgets;

    //
    int p_scrollDelta = 20;
    int p_minSize = 40;
    int p_maxSize = 999;
    bool p_showVerticalScrollButton = true;
    bool p_showHorizontalScrollButton = true;
    Background p_background = Background.light;

    bool p_allowResize = false;
    bool p_allowHide = false;
    bool p_allowDrag = false;
    bool p_isOpen = true;
    bool p_blackSplit = false;
    bool p_showSplit = true;
    utfstring p_caption = "Hello World!";

    @property
    bool scrollButtonIsClicked() {
        return verticalScrollButton.isClick || horizontalScrollButton.isClick;
    }

    void updateScroll() {
    }

    void pollScroll() {
    }

    void calculateSplit() {
    }

    void renderSplit() {
    }

    void renderScroll() {
    }

    void scrollToWidget() {
    }
}

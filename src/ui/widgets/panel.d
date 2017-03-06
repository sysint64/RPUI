module ui.widgets.panel;

import std.container;
import std.algorithm.comparison;
import std.stdio;

import basic_types;
import math.linalg;
import gapi;
import log;
import input;

import ui.widget;
import ui.manager;
import ui.cursor;
import ui.render_objects;


class Panel : Widget {
    enum Background {transparent, light, dark, action};

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

        calculateSplit();

        if (allowHide) {
        }

        if (!isOpen) {
            updateAlign();
            padding.top = lastPaddingTop;
            renderSplit();
            return;
        }

        string state = "Leave";
        renderer.renderVerticalChain(verticalScrollButton.buttonRenderObjects,
                                     state, absolutePosition, vec2(10, 100));

        // Render children
        Rect scissor;
        scissor.point = vec2(absolutePosition.x, absolutePosition.y + scissorHeader);
        scissor.size = vec2(size.x, size.y - scissorHeader);
        manager.pushScissor(scissor);

        if (split.isClick)
            pollSplitResize();

        super.render(camera);

        manager.popScissor();

        renderScroll();
        renderSplit();
	updateAlign();
    }

    override void onCreate() {
        renderFactory.createQuad(backgroundRenderObject);
        renderFactory.createQuad(splitBorderRenderObject);
        renderFactory.createQuad(splitInnerRenderObject);

        with (manager.theme) {
            backgroundColors[Background.light]  = data.getNormColor(style ~ ".backgroundLight");
            backgroundColors[Background.dark]   = data.getNormColor(style ~ ".backgroundDark");
            backgroundColors[Background.action] = data.getNormColor(style ~ ".backgroundAction");

            split.thickness = data.getNumber(style ~ ".Split.thickness.0");

            const auto addSplitColor = delegate(in string key) {
                splitColors[key] = manager.theme.data.getNormColor(style ~ "." ~ key);
            };

            addSplitColor(spliteState(false, false));
            addSplitColor(spliteState(false, true));
            addSplitColor(spliteState(true , false));
            addSplitColor(spliteState(true , true));

            // Scroll
            immutable string[3] states = ["Leave", "Enter", "Click"];
            immutable string[3] horizontalParts = ["left", "center", "right"];
            immutable string[3] verticalParts = ["top", "middle", "bottom"];

            immutable string scrollHorizontalBgStyle = style ~ ".Scroll.Horizontal";
            immutable string scrollVerticalBgStyle = style ~ ".Scroll.Vertical";
            immutable string scrollHorizontalButtonStyle = style ~ ".Scroll.Horizontal.Button";
            immutable string scrollVerticalButtonStyle = style ~ ".Scroll.Vertical.Button";

            foreach (string part; verticalParts) {
                // renderFactory.createQuad(scrollBackgroundRenderObjects, scrollButtonBgStyle,
                //                          elements, key);
                renderFactory.createQuad(verticalScrollButton.buttonRenderObjects,
                                         scrollVerticalButtonStyle, states, part);
            }
        }
    }

    override void onCursor() {
        if (!resizable || !isOpen || verticalScrollButton.isClick || horizontalScrollButton.isClick)
            return;

        if (regionAlign == RegionAlign.top || regionAlign == RegionAlign.bottom) {
            const Rect rect = Rect(split.borderPosition.x,
                                   split.borderPosition.y - split.cursorRangeSize / 2.0f,
                                   split.size.x, split.cursorRangeSize);

            if (pointInRect(app.mousePos, rect) || split.isClick) {
                manager.cursor = Cursor.Icon.vDoubleArrow;
                split.isEnter = true;
            }
        } else if (regionAlign == RegionAlign.left || regionAlign == RegionAlign.right) {
            const Rect rect = Rect(split.borderPosition.x - split.cursorRangeSize / 2.0f,
                                   split.borderPosition.y,
                                   split.cursorRangeSize, split.size.y);

            if (pointInRect(app.mousePos, rect) || split.isClick) {
                manager.cursor = Cursor.Icon.hDoubleArrow;
                split.isEnter = true;
            }
        }
    }

    override void onMouseDown(in uint x, in uint y, in MouseButton button) {
        if (split.isEnter && isOpen) {
            lastSize = size;
            split.isClick = true;
        }
    }

    override void onMouseUp(in uint x, in uint y, in MouseButton button) {
        super.onMouseDown(x, y, button);

        verticalScrollButton.isClick = false;
        horizontalScrollButton.isClick = false;
        split.isClick = false;
    }

    // Properties ----------------------------------------------------------------------------------

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

    @property ref float minSize() { return p_minSize; }
    @property void minSize(in float val) { p_minSize = val; }

    @property ref float maxSize() { return p_maxSize; }
    @property void maxSize(in float val) { p_maxSize = val; }

protected:
    override void updateAlign() {
        if (regionAlign == RegionAlign.none)
            return;

        const FrameRect region = findRegion();
        const vec2 scrollRegion = vec2(0, 0);  // TODO: make real region
        const vec2 regionSize = vec2(parent.size.x - region.right  - region.left - scrollRegion.x,
                                     parent.size.y - region.bottom - region.top  - scrollRegion.y);

        switch (regionAlign) {
            case RegionAlign.client:
                size.x = regionSize.x;
                size.y = regionSize.y;
                position = vec2(region.left, region.top);
                break;

            case RegionAlign.top:
                size.x = regionSize.x;
                position = vec2(region.left, region.top);
                break;

            case RegionAlign.bottom:
                size.x = regionSize.x;
                position.x = region.left;
                position.y = parent.size.y - size.y - region.bottom - scrollRegion.y;
                break;

            case RegionAlign.left:
                size.y = regionSize.y;
                position = vec2(region.left, region.top);
                break;

            case RegionAlign.right:
                size.y = regionSize.y;
                position.x = parent.size.x - size.x - region.right - scrollRegion.x;
                position.y = region.top;
                break;

            default:
                break;
        }
    }

private:
    BaseRenderObject splitBorderRenderObject;
    BaseRenderObject splitInnerRenderObject;
    BaseRenderObject headerRenderObject;
    BaseRenderObject expandArrowRenderObject;
    BaseRenderObject backgroundRenderObject;
    TextRenderObject textRenderObject;

    vec4[Background] backgroundColors;
    vec4[string] splitColors;

    vec2 widgetsOffset;

    struct Split {
        bool isEnter = false;
        bool isClick = false;
        float thickness = 1;
        float cursorRangeSize = 8;
        Rect cursorRangeRect;
        vec2 borderPosition;
        vec2 innerPosition;
        vec2 size;
    }

    Split split;

    float panelSize;
    float currentPanelSize;

    float headerSize = 0;
    bool headerIsEnter = false;

    struct ScrollButton {
        BaseRenderObject[string] backgroundRenderObjects;
        BaseRenderObject[string] buttonRenderObjects;

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
    float p_minSize = 40;
    float p_maxSize = 999;
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

    vec2 lastSize = 0;

    string spliteState(in bool innerColor, in bool useBlackColor = false) const {
        const string color = innerColor ? "innerColor" : "borderColor";
        return p_blackSplit || useBlackColor ? "Split.Dark." ~ color : "Split.Light." ~ color;
    }

    @property
    bool scrollButtonIsClicked() {
        return verticalScrollButton.isClick || horizontalScrollButton.isClick;
    }

    FrameRect findRegion() {
        FrameRect region;

        foreach (uint index, Widget widget; parent.children) {
            if (widget == this)
                break;

            if (!widget.visible || widget.regionAlign == RegionAlign.none)
                continue;

            switch (widget.regionAlign) {
                case RegionAlign.top:
                    region.top += widget.size.y;
                    break;

                case RegionAlign.left:
                    region.left += widget.size.x;
                    break;

                case RegionAlign.bottom:
                    region.bottom += widget.size.y;
                    break;

                case RegionAlign.right:
                    region.right += widget.size.x;
                    break;

                default:
                    continue;
            }
        }

        return region;
    }

    void updateScroll() {
    }

    void pollScroll() {
    }

    void pollSplitResize() {
        switch (regionAlign) {
            case RegionAlign.top:
                size.y = lastSize.y + app.mousePos.y - app.mouseClickPos.y;
                break;

            case RegionAlign.bottom:
                size.y = lastSize.y - app.mousePos.y + app.mouseClickPos.y;
                break;

            case RegionAlign.left:
                size.x = lastSize.x + app.mousePos.x - app.mouseClickPos.x;
                break;

            case RegionAlign.right:
                size.x = lastSize.x - app.mousePos.x + app.mouseClickPos.x;
                break;

            default:
                break;
        }

        if (regionAlign == RegionAlign.top || regionAlign == RegionAlign.bottom)
            size.y = clamp(size.y, minSize, maxSize);

        if (regionAlign == RegionAlign.left || regionAlign == RegionAlign.right)
            size.x = clamp(size.x, minSize, maxSize);
    }

    void calculateSplit() {
        if (!resizable && !showSplit)
            return;

        switch (regionAlign) {
            case RegionAlign.top:
                split.borderPosition = absolutePosition + vec2(0, size.y - split.thickness);
                split.innerPosition = split.borderPosition - vec2(0, split.thickness);
                split.size = vec2(size.x, split.thickness);
                break;

            case RegionAlign.bottom:
                split.borderPosition = absolutePosition;
                split.innerPosition = split.borderPosition + vec2(0, split.thickness);
                split.size = vec2(size.x, split.thickness);
                break;

            case RegionAlign.left:
                split.borderPosition = absolutePosition + vec2(size.x - split.thickness, 0);
                split.innerPosition = split.borderPosition - vec2(split.thickness, 0);
                split.size = vec2(split.thickness, size.y);
                break;

            case RegionAlign.right:
                split.borderPosition = absolutePosition;
                split.innerPosition = split.borderPosition + vec2(split.thickness, 0);
                split.size = vec2(split.thickness, size.y);
                break;

            default:
                return;
        }
    }

    void renderSplit() {
        if (!resizable && !showSplit)
            return;

        renderer.renderColorQuad(splitBorderRenderObject, splitColors[spliteState(false)],
                                 split.borderPosition, split.size);
        renderer.renderColorQuad(splitInnerRenderObject, splitColors[spliteState(true)],
                                 split.innerPosition, split.size);
    }

    void renderScroll() {
    }

    void scrollToWidget() {
    }
}

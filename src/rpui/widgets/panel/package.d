/**
 * Copyright: © 2017 Andrey Kabylin
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 */

module rpui.widgets.panel;

import std.container;
import std.algorithm.comparison;
import std.stdio;

import basic_types;
import math.linalg;
import gapi;
import rpdl;
import log;
import input;

import rpui.widget;
import rpui.scroll;
import rpui.manager;
import rpui.cursor;
import rpui.render_objects;
import rpui.events;
import rpui.widget_events;

import rpui.widgets.panel.split;
import rpui.widgets.panel.header;
import rpui.widgets.panel.scroll_button;

/**
 * Panel widget is the container for other widgets with scrolling,
 * resizing, allow change placement by drag and drop.
 */
class Panel : Widget, FocusScrollNavigation {
    enum Background {
        transparent,  /// Render without color.
        light,
        dark,
        action  /// Color for actions like OK, Cancel etc.
    }

    @Field float minSize = 40;  /// Minimum size of panel.
    @Field float maxSize = 999;  /// Maximum size of panel.
    @Field Background background = Background.light;  /// Background color of panel.
    @Field bool userCanResize = true;
    @Field bool userCanHide = false;
    @Field bool userCanDrag = false;

    /// If true, then panel is open and will be rendered all content else only header.
    @Field bool isOpen = true;
    @Field bool blackSplit = false;  /// If true, then panel split will be black.
    @Field bool showSplit = true;  /// If true, render panel split else no.

    @Field bool showVerticalScrollButton = true;
    @Field bool showHorizontalScrollButton = true;

    private utf32string p_caption = "";

    @Field
    @property void caption(utf32string value) {
        if (manager is null) {
            p_caption = value;
        } else {
            p_caption = value;
            header.textRenderObject.text = value;
        }
    }

    @property utf32string caption() { return p_caption; }

    @property
    void showScrollButtons(in bool val) {
        showVerticalScrollButton = val;
        showHorizontalScrollButton = val;
    }

    this(in string style = "Panel") {
        super(style);
        skipFocus = true;
    }

    override void progress() {
        super.progress();
        split.isEnter = false;

        handleResize();
        header.progress();

        // Update render elements position and sizes
        locator.updateRegionAlign();
        locator.updateAbsolutePosition();
        updateInnerOffset();
        updateSize();

        if (!isFreezingSource() && !isFrozen()) {
            horizontalScrollButton.progress();
            verticalScrollButton.progress();
        } else {
            horizontalScrollButton.isEnter = false;
            verticalScrollButton.isEnter = false;
        }
    }

    override void updateSize() {
        if (isOpen) {
            horizontalScrollButton.updateSize();
            verticalScrollButton.updateSize();
            updatePanelSize();
        }

        split.calculate();

        with (horizontalScrollButton)
            contentOffset.x = visible ? scrollController.contentOffset : 0;

        with (verticalScrollButton)
            contentOffset.y = visible ? scrollController.contentOffset : 0;
    }

    private void updatePanelSize() {
        if (heightType == SizeType.wrapContent) {
            size.y = innerBoundarySize.y;
        }

        if (widthType == SizeType.wrapContent) {
            size.x = innerBoundarySize.x;
        }
    }

    override void render(Camera camera) {
        if (background != Background.transparent) {
            renderer.renderColoredObject(
                backgroundRenderObject,
                backgroundColors[background],
                absolutePosition, outerBoundarySize
            );
        }

        header.render();

        if (!isOpen) {
            split.render();
            return;
        }

        // Render children widgets
        Rect scissor;

        scissor.point = absolutePosition + extraInnerOffsetStart;
        scissor.size = size;

        if (userCanHide) {
            scissor.size = scissor.size - vec2(0, header.height);
        }

        if (userCanResize && blackSplit) {
            switch (split.orientation) {
                case Orientation.horizontal:
                    scissor.size = scissor.size - vec2(0, split.thickness);
                    break;

                case Orientation.vertical:
                    scissor.size = scissor.size - vec2(split.thickness, 0);
                    break;

                default:
                    break;
            }
        }

        manager.pushScissor(scissor);

        foreach (Widget widget; children) {
            if (!widget.visible)
                continue;

            if (!pointInRect(app.mousePos, scissor)) {
                widget.isEnter = false;
                widget.isClick = false;
            }

            widget.render(camera);
        }

        manager.popScissor();
        split.render();

        horizontalScrollButton.render();
        verticalScrollButton.render();
    }

    override void scrollToWidget(Widget widget) {
        const vec2 relativePosition = widget.absolutePosition -
            (absolutePosition + extraInnerOffsetStart);

        with (verticalScrollButton.scrollController)
            setOffsetInPx(relativePosition.y + contentOffset);

        with (horizontalScrollButton.scrollController)
            setOffsetInPx(relativePosition.x + contentOffset);
    }

    override void borderScrollToWidget(Widget widget) {
        const vec2 relativePosition = widget.absolutePosition -
            (absolutePosition + extraInnerOffsetStart);

        with (verticalScrollButton.scrollController) {
            const float innerVisibleSize = visibleSize - extraInnerOffsetSize.y;
            const float widgetScrollOffset = relativePosition.y + contentOffset;

            if (relativePosition.y < 0) {
                setOffsetInPx(widgetScrollOffset);
            } else if (relativePosition.y + widget.size.y > innerVisibleSize) {
                setOffsetInPx(widgetScrollOffset - innerVisibleSize + widget.size.y);
            }
        }

        with (horizontalScrollButton.scrollController) {
            const float innerVisibleSize = visibleSize - extraInnerOffsetSize.x;
            const float widgetScrollOffset = relativePosition.x + contentOffset;

            if (relativePosition.x < 0) {
                setOffsetInPx(widgetScrollOffset);
            } else if (relativePosition.x + widget.size.x > innerVisibleSize) {
                setOffsetInPx(widgetScrollOffset - innerVisibleSize + widget.size.x);
            }
        }
    }

    /// Set scroll value in px.
    void scrollToPx(in float x, in float y) {
        verticalScrollButton.scrollController.setOffsetInPx(x);
        horizontalScrollButton.scrollController.setOffsetInPx(y);
    }

    /// Add value to scroll in px.
    void scrollByPx(in float dx, in float dy) {
        verticalScrollButton.scrollController.addOffsetInPx(dx);
        horizontalScrollButton.scrollController.addOffsetInPx(dy);
    }

    /// Set scroll value in percent.
    void scrollToPercent(in float x, in float y) {
        verticalScrollButton.scrollController.setOffsetInPercent(x);
        horizontalScrollButton.scrollController.setOffsetInPercent(y);
    }

// Events ------------------------------------------------------------------------------------------

    /**
     * Create elements for widget rendering (quads, texts etc.)
     * and read data from theme for these elements (background color, split thickness etc.).
     */
    override void onCreate() {
        super.onCreate();

        events.subscribe!FocusFrontEvent(&open);
        events.subscribe!FocusBackEvent(&open);

        renderFactory.createQuad(backgroundRenderObject);

        with (manager.theme.tree) {
            // Panel background colors
            backgroundColors[Background.light]  = data.getNormColor(style ~ ".backgroundLight");
            backgroundColors[Background.dark]   = data.getNormColor(style ~ ".backgroundDark");
            backgroundColors[Background.action] = data.getNormColor(style ~ ".backgroundAction");
        }

        split.onCreate(this, manager.theme, renderer);
        horizontalScrollButton.onCreate(this, manager.theme, renderer);
        verticalScrollButton.onCreate(this, manager.theme, renderer);
        header.onCreate(this, manager.theme, renderer);
    }

    /// Change system cursor when mouse entering split.
    override void onCursor() {
        if (!userCanResize || !isOpen || scrollButtonIsClicked)
            return;

        if (regionAlign == RegionAlign.top || regionAlign == RegionAlign.bottom) {
            const Rect rect = Rect(
                split.borderPosition.x,
                split.borderPosition.y - split.cursorRangeSize / 2.0f,
                split.size.x, split.cursorRangeSize
            );

            if (pointInRect(app.mousePos, rect) || split.isClick) {
                manager.cursor = Cursor.Icon.vDoubleArrow;
                split.isEnter = true;
                horizontalScrollButton.isEnter = false;
            }
        } else if (regionAlign == RegionAlign.left || regionAlign == RegionAlign.right) {
            const Rect rect = Rect(
                split.borderPosition.x - split.cursorRangeSize / 2.0f,
                split.borderPosition.y,
                split.cursorRangeSize, split.size.y
            );

            if (pointInRect(app.mousePos, rect) || split.isClick) {
                manager.cursor = Cursor.Icon.hDoubleArrow;
                split.isEnter = true;
                verticalScrollButton.isEnter = false;
            }
        }
    }

    /// Handle mouse down event - avoid it if UI is forzen.
    override void onMouseDown(in MouseDownEvent event) {
        if (isFreezingSource() && manager.isNestedFreeze)
            return;

        if (split.isEnter && isOpen && manager.cursor != Cursor.Icon.inherit) {
            lastSize = size;
            split.isClick = true;
            freezeUI();
        }

        if (!isFreezingSource()) {
            verticalScrollButton.isClick = verticalScrollButton.isEnter;
            horizontalScrollButton.isClick = horizontalScrollButton.isEnter;

            verticalScrollButton.scrollController.onMouseDown(event);
            horizontalScrollButton.scrollController.onMouseDown(event);
        }

        onHeaderMouseDown();
        super.onMouseDown(event);
    }

    private void onHeaderMouseDown() {
        if (!header.isEnter || !userCanHide)
            return;

        toggle();
    }

    final void open() {
        if (isOpen)
            return;

        size = lastSize;
        isOpen = true;
        manager.rootWidget.updateAll();
    }

    final void close() {
        if (!isOpen)
            return;

        lastSize = size;
        size.y = header.height;
        isOpen = false;
        manager.rootWidget.updateAll();

        horizontalScrollButton.scrollController.setOffsetInPercent(0);
        verticalScrollButton.scrollController.setOffsetInPercent(0);
    }

    /// Toggle visibility of panel. If `isOpen` then method will close panel else open.
    final void toggle() {
        if (isOpen) {
            close();
        } else {
            open();
        }
    }

    override void onMouseUp(in MouseUpEvent event) {
        verticalScrollButton.isClick = false;
        horizontalScrollButton.isClick = false;

        if (split.isClick) {
            split.isClick = false;
            unfreezeUI();
        }

        super.onMouseUp(event);
    }

    override void onResize() {
        horizontalScrollButton.scrollController.onResize();
        verticalScrollButton.scrollController.onResize();

        super.onResize();
    }

protected:
    /// Add extra inner offset depends of which elements are visible.
    void updateInnerOffset() {
        extraInnerOffset.left = 0;

        if (verticalScrollButton.visible) {
            extraInnerOffset.right = verticalScrollButton.width;
        } else {
            extraInnerOffset.right = 0;
        }

        if (horizontalScrollButton.visible) {
            extraInnerOffset.bottom = horizontalScrollButton.width;
        } else {
            extraInnerOffset.bottom = 0;
        }

        if (userCanHide) {
            extraInnerOffset.top = header.height;
        } else {
            extraInnerOffset.top = 0;
        }

        // Split extra inner offset
        if (userCanResize || showSplit) {
            const thickness = 1;

            switch (regionAlign) {
                case RegionAlign.top:
                    extraInnerOffset.bottom += thickness;
                    break;

                case RegionAlign.bottom:
                    extraInnerOffset.top += thickness;
                    break;

                case RegionAlign.right:
                    extraInnerOffset.left += thickness;
                    break;

                case RegionAlign.left:
                    extraInnerOffset.right += thickness;
                    break;

                default:
                    break;
            }
        }
    }

    void onMouseWheelHandle(in int dx, in int dy) {
        if (isFreezingSource() && manager.isNestedFreeze)
            return;

        Scrollable scrollable = cast(Scrollable) parent;

        int horizontalDelta = dx;
        int verticalDelta = dy;

        if (!verticalScrollButton.scrollController.addOffsetInPx(-verticalDelta*20)) {
            if (scrollable && parent.isOver && !parent.isFrozen()) {
                scrollable.onMouseWheelHandle(0, verticalDelta);
            }
        }

        if (!horizontalScrollButton.scrollController.addOffsetInPx(-horizontalDelta*20)) {
            if (scrollable && parent.isOver && !parent.isFrozen()) {
                scrollable.onMouseWheelHandle(horizontalDelta, 0);
            }
        }
    }

private:
    BaseRenderObject backgroundRenderObject;
    TextRenderObject textRenderObject;

    vec4[Background] backgroundColors;
    vec2 widgetsOffset;

    Split split;
    Header header;

    float panelSize;
    float currentPanelSize;

    ScrollButton verticalScrollButton   = ScrollButton(Orientation.vertical);
    ScrollButton horizontalScrollButton = ScrollButton(Orientation.horizontal);

    Array!Widget joinedWidgets;

    vec2 lastSize = 0;

    @property
    bool scrollButtonIsClicked() {
        return verticalScrollButton.isClick || horizontalScrollButton.isClick;
    }

    // Resize panel when split is clicked.
    void handleResize() {
        if (!split.isClick)
            return;

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

        parent.events.notify(ResizeEvent());
        manager.rootWidget.updateAll();
    }
}

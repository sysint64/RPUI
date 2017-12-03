/**
 * Panel widget.
 *
 * Copyright: © 2017 RedGoosePaws
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 * Authors: Andrey Kabylin
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
    @Field bool allowResize = false;  /// If true, user can change size of panel.
    @Field bool allowHide = false;  /// If true, user can hide and show panel.
    @Field bool allowDrag = false;  /// If true, user can change ordering of panels.

    /// If true, then panel is open and will be rendered all content else only header.
    @Field bool isOpen = true;
    @Field bool blackSplit = false;  /// If true, then panel split will be black.
    @Field bool showSplit = true;  /// If true, render panel split else no.

    @Field bool showVerticalScrollButton = true;
    @Field bool showHorizontalScrollButton = true;

    private utfstring p_caption = "";

    @Field
    @property void caption(utfstring value) {
        if (manager is null) {
            p_caption = value;
        } else {
            p_caption = value;
            header.textRenderObject.text = value;
        }
    }

    @property utfstring caption() { return p_caption; }

    /// Set `showVerticalScrollButton` and `showHorizontalScrollButton` to `val`.
    @property
    void showScrollButtons(in bool val) {
        showVerticalScrollButton = val;
        showHorizontalScrollButton = val;
    }

    /// Create panel with custom `style`.
    this(in string style = "Panel") {
        super(style);
        skipFocus = true;
    }

    override void onProgress() {
        super.onProgress();
        split.isEnter = false;

        handleResize();
        header.onProgress();

        // Update render elements position and sizes
        updateRegionAlign();
        updateAbsolutePosition();
        updateInnerOffset();
        updateResize();

        if (!isFreezingSource() && !isFrozen()) {
            horizontalScrollButton.onProgress();
            verticalScrollButton.onProgress();
        } else {
            horizontalScrollButton.isEnter = false;
            verticalScrollButton.isEnter = false;
        }
    }

    override void updateResize() {
        horizontalScrollButton.updateResize();
        verticalScrollButton.updateResize();

        split.calculate();

        with (horizontalScrollButton)
            contentOffset.x = visible ? scrollController.contentOffset : 0;

        with (verticalScrollButton)
            contentOffset.y = visible ? scrollController.contentOffset : 0;
    }

    override void render(Camera camera) {
        if (background != Background.transparent) {
            renderer.renderColorQuad(
                backgroundRenderObject,
                backgroundColors[background],
                absolutePosition, size
            );
        }

        header.render();

        if (!isOpen) {
            split.render();
            return;
        }

        horizontalScrollButton.render();
        verticalScrollButton.render();

        // Render children widgets
        Rect scissor;
        scissor.point = vec2(
            absolutePosition.x + extraInnerOffset.left,
            absolutePosition.y + extraInnerOffset.top
        );
        scissor.size = vec2(
            size.x - extraInnerOffset.left - extraInnerOffset.right,
            size.y - extraInnerOffset.top - extraInnerOffset.bottom
        );

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
        if (!resizable || !isOpen || scrollButtonIsClicked)
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
    override void onMouseDown(in uint x, in uint y, in MouseButton button) {
        if (isFreezingSource() && manager.isNestedFreeze)
            return;

        if (split.isEnter && isOpen) {
            lastSize = size;
            split.isClick = true;
            freezeUI();
        }

        if (!isFreezingSource()) {
            verticalScrollButton.isClick = verticalScrollButton.isEnter;
            horizontalScrollButton.isClick = horizontalScrollButton.isEnter;

            verticalScrollButton.scrollController.onMouseDown(x, y, button);
            horizontalScrollButton.scrollController.onMouseDown(x, y, button);
        }

        onHeaderMouseDown();
        super.onMouseDown(x, y, button);
    }

    private void onHeaderMouseDown() {
        if (!header.isEnter || !allowHide)
            return;

        toggle();
    }

    /// Open panel.
    final void open() {
        if (isOpen)
            return;

        size = lastSize;
        isOpen = true;
    }

    /// Close panel.
    final void close() {
        if (!isOpen)
            return;

        lastSize = size;
        size.y = header.height;
        isOpen = false;

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

    override void onMouseUp(in uint x, in uint y, in MouseButton button) {
        verticalScrollButton.isClick = false;
        horizontalScrollButton.isClick = false;

        if (split.isClick) {
            split.isClick = false;
            unfreezeUI();
        }

        super.onMouseUp(x, y, button);
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

        if (allowHide) {
            extraInnerOffset.top = header.height;
        } else {
            extraInnerOffset.top = 0;
        }

        // Split extra inner offset
        if (allowResize || showSplit) {
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

    override void navFocusFront() {
        open();
        super.navFocusFront();
    }

    override void navFocusBack() {
        open();
        super.navFocusBack();
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

        parent.updateAll();
        parent.onResize();
    }
}

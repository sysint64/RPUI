module ui.widgets.panel.widget;

import std.container;
import std.algorithm.comparison;
import std.stdio;

import basic_types;
import math.linalg;
import gapi;
import rpdl;
import log;
import input;

import ui.widget;
import ui.scroll;
import ui.manager;
import ui.cursor;
import ui.render_objects;

import ui.widgets.panel.split;
import ui.widgets.panel.header;
import ui.widgets.panel.scroll_button;


class Panel : Widget, Scrollable, FocusScrollNavigation {
    enum Background {transparent, light, dark, action};

    @Field float minSize = 40;
    @Field float maxSize = 999;
    @Field Background background = Background.light;
    @Field bool allowResize = false;
    @Field bool allowHide = false;
    @Field bool allowDrag = false;
    @Field bool isOpen = true;
    @Field bool blackSplit = false;
    @Field bool showSplit = true;

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

    @property
    void showScrollButtons(in bool val) {
        showVerticalScrollButton = val;
        showHorizontalScrollButton = val;
    }

    this() {
        super("Panel");
        skipFocus = true;
    }

    this(in string style) {
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

        if (!isFrozeSource() && !isFroze()) {
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
        super.render(camera);
        manager.popScissor();

        split.render();
    }

    void scrollToWidget(Widget widget) {
        const vec2 relativePosition = widget.absolutePosition -
            (absolutePosition + extraInnerOffsetStart);

        with (verticalScrollButton.scrollController)
            setOffsetInPx(relativePosition.y + contentOffset);

        with (horizontalScrollButton.scrollController)
            setOffsetInPx(relativePosition.x + contentOffset);
    }

    // Scroll to widget if it out of visible region.
    // Scroll on top border if widget above and bottom if below visible region.
    void borderScrollToWidget(Widget widget) {
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

    void scrollToPx(in float x, in float y) {
        verticalScrollButton.scrollController.setOffsetInPx(x);
        horizontalScrollButton.scrollController.setOffsetInPx(y);
    }

    void scrollByPx(in float dx, in float dy) {
        verticalScrollButton.scrollController.addOffsetInPx(dx);
        horizontalScrollButton.scrollController.addOffsetInPx(dy);
    }

    void scrollToPercent(in float x, in float y) {
        verticalScrollButton.scrollController.setOffsetInPercent(x);
        horizontalScrollButton.scrollController.setOffsetInPercent(y);
    }

// Events ------------------------------------------------------------------------------------------

    // Create elements for widget rendering (quads, texts etc.)
    // and read data from theme for these elements (background color, split thickness etc.)
    override void onCreate() {
        super.onCreate();
        renderFactory.createQuad(backgroundRenderObject);

        with (manager.theme) {
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

    // Change system cursor when mouse entering split
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

    override void onMouseDown(in uint x, in uint y, in MouseButton button) {
        if (isFrozeSource() && manager.isNestedFreeze)
            return;

        if (split.isEnter && isOpen) {
            lastSize = size;
            split.isClick = true;
            freezeUI();
        }

        if (!isFrozeSource()) {
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

    final void open() {
        if (isOpen)
            return;

        size = lastSize;
        isOpen = true;
    }

    final void close() {
        if (!isOpen)
            return;

        lastSize = size;
        size.y = header.height;
        isOpen = false;

        horizontalScrollButton.scrollController.setOffsetInPercent(0);
        verticalScrollButton.scrollController.setOffsetInPercent(0);
    }

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
    void updateInnerOffset() {
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

        if (allowResize || showSplit) {
            extraInnerOffset.bottom += split.thickness;
        }
    }

    void onMouseWheelHandle(in int dx, in int dy) {
        if (isFrozeSource() && manager.isNestedFreeze)
            return;

        Scrollable scrollable = cast(Scrollable) parent;

        int horizontalDelta = dx;
        int verticalDelta = dy;

        if (!verticalScrollButton.scrollController.addOffsetInPx(-verticalDelta*20)) {
            if (scrollable && parent.isOver && !parent.isFroze()) {
                scrollable.onMouseWheelHandle(0, verticalDelta);
            }
        }

        if (!horizontalScrollButton.scrollController.addOffsetInPx(-horizontalDelta*20)) {
            if (scrollable && parent.isOver && !parent.isFroze()) {
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

    // Resize panel when split is clicked
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

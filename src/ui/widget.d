module ui.widget;

import std.container;
import std.conv;
import std.math;

import input;
import gapi;
import application;
import math.linalg;
import basic_types;

import ui.manager;
import ui.render_factory;
import ui.render_objects;
import ui.cursor;
import ui.renderer;
import ui.scroll;


interface Scrollable {
    void onMouseWheelHandle(in int dx, in int dy);
    void scrollToWidget(Widget widget);
}


class Widget {
    struct Field {
        string name = "";
    }

    alias Array!Widget Children;

// Properties --------------------------------------------------------------------------------------

    @Field bool resizable = true;  // ???
    @Field bool withoutSkin = false;
    @Field bool visible = true;
    @Field bool enabled = true;
    @Field bool finalFocus = false;
    @Field bool autoWidth;
    @Field bool autoHeight;
    @Field Cursor.Icon cursor;
    @Field string name = "";
    @Field int tag = 0;
    @Field utfstring hint = "";
    @Field Align locationAlign = Align.none;
    @Field VerticalAlign locationVerticalAlign = VerticalAlign.none;
    @Field RegionAlign regionAlign = RegionAlign.none;
    @Field FrameRect margin = FrameRect(0, 0, 0, 0);
    @Field FrameRect padding = FrameRect(0, 0, 0, 0);
    @Field vec2 position = vec2(0, 0);
    @Field vec2 size = vec2(0, 0);

    @property uint id() { return p_id; }
    @property string style() { return p_style; }
    @property Widget parent() { return p_parent; }
    @property bool isFocused() { return p_isFocused; }

    @property Widget nextWidget() { return p_nextWidget; }
    @property Widget prevWidget() { return p_prevWidget; }
    @property Widget lastWidget() { return p_lastWidget; }
    @property Widget firstWidget() { return p_firstWidget; }

    @property Widget associatedWidget() { return p_associatedWidget; }

    @property ref Children children() { return p_children; }
    @property final RenderFactory renderFactory() { return manager.renderFactory; }

    @property final inout(string) state() inout {
        if (isClick) {
            return "Click";
        } else if (isEnter) {
            return "Enter";
        } else {
            return "Leave";
        }
    }

    // Inner size considering the extra innter offsets and padding
    @property final vec2 innerSize() {
        return size - innerOffsetSize;
    }

    @property final vec2 innerOffsetSize() {
        return vec2(
            padding.left + padding.right + extraInnerOffset.left + extraInnerOffset.right,
            padding.top + padding.bottom + extraInnerOffset.top + extraInnerOffset.bottom
        );
    }

    @property final FrameRect innerOffset() {
        return FrameRect(
            padding.left + extraInnerOffset.left,
            padding.top + extraInnerOffset.top,
            padding.right + extraInnerOffset.right,
            padding.bottom + extraInnerOffset.bottom,
        );
    }

    @property final vec2 innerOffsetStart() {
        return vec2(innerOffset.left, innerOffset.top);
    }

    @property final vec2 innerOffsetEnd() {
        return vec2(innerOffset.right, innerOffset.bottom);
    }

    // Outer size considering the extra outer offsets and margin
    @property final vec2 outerSize() {
        return size + outerOffsetSize;
    }

    @property final vec2 outerOffsetSize() {
        return vec2(
            margin.left + margin.right + extraOuterOffset.left + extraOuterOffset.right,
            margin.top + margin.bottom + extraOuterOffset.top + extraOuterOffset.bottom
        );
    }

    @property final FrameRect outerOffset() {
        return FrameRect(
            margin.left + extraOuterOffset.left,
            margin.top + extraOuterOffset.top,
            margin.right + extraOuterOffset.right,
            margin.bottom + extraOuterOffset.bottom,
        );
    }

    @property final vec2 outerOffsetStart() {
        return vec2(outerOffset.left, outerOffset.top);
    }

    @property final vec2 outerOffsetEnd() {
        return vec2(outerOffset.right, outerOffset.bottom);
    }

private:
    Camera camera = null;
    Children p_children;

    uint p_id;
    string p_style;
    Widget p_parent;

    // Navigation (for focus)
    Widget p_nextWidget = null;
    Widget p_prevWidget = null;
    Widget p_lastWidget = null;
    Widget p_firstWidget = null;

    Widget p_associatedWidget = null;

protected:
    enum PartDraws {all, left, center, right};

    Application app;
    Manager manager;
    PartDraws partDraws;

package:
    bool p_isFocused;
    bool skipFocus = false;
    bool drawChildren = true;
    FrameRect extraInnerOffset = FrameRect(0, 0, 0, 0);  // extra inner offset besides padding
    FrameRect extraOuterOffset = FrameRect(0, 0, 0, 0);  // extra outer offset besides margin
    bool overlay;
    vec2 overSize;
    bool isEnter;
    bool isClick;
    bool isOver;  // When in rect of element but if another element over this
                  // isOver will still be true

    vec2 absolutePosition = vec2(0, 0);
    vec2 innerBoundarySizeClamped = vec2(0, 0);
    vec2 innerBoundarySize = vec2(0, 0);
    vec2 contentOffset = vec2(0, 0);

    @property void associatedWidget(Widget val) { p_associatedWidget = val; }

// Event Listeners ---------------------------------------------------------------------------------

public:
    alias void delegate(Widget) OnClickListener;
    alias void delegate(Widget) OnDblClickistener;
    alias void delegate(Widget) OnFocusListener;
    alias void delegate(Widget) OnBlurListener;
    alias void delegate(Widget, in KeyCode key) OnKeyPressedListener;
    alias void delegate(Widget, in KeyCode key) OnKeyReleasedListener;
    alias void delegate(Widget, in utfchar key) OnTextEnteredListener;
    alias void delegate(Widget, in uint x, in uint y) OnMouseMoveListener;
    alias void delegate(Widget, in uint x, in uint y) OnMouseEnterListener;
    alias void delegate(Widget, in uint x, in uint y) OnMouseLeaveListener;
    alias void delegate(Widget, in uint x, in uint y, in MouseButton button) OnMouseDownListener;
    alias void delegate(Widget, in uint x, in uint y, in MouseButton button) OnMouseUpListener;

    OnClickListener onClickListener = null;
    OnDblClickistener onDblClickistener = null;
    OnFocusListener onFocusListener = null;
    OnBlurListener onBlurListener = null;
    OnKeyPressedListener onKeyPressedListener = null;
    OnKeyReleasedListener onKeyReleasedListener = null;
    OnTextEnteredListener onTextEnteredListener = null;
    OnMouseMoveListener onMouseMoveListener = null;
    OnMouseEnterListener onMouseEnterListener = null;
    OnMouseLeaveListener onMouseLeaveListener = null;
    OnMouseDownListener onMouseDownListener = null;
    OnMouseUpListener onMouseUpListener = null;

// Events triggers ---------------------------------------------------------------------------------

    void triggerClick() {
        if (onClickListener !is null)
            onClickListener(this);
    }

// Implementation ----------------------------------------------------------------------------------

    this() {
        app = Application.getInstance();
    }

    this(in string style) {
        app = Application.getInstance();
        this.p_style = style;
    }

    void updateBoundary() {
        if (!drawChildren)
            return;

        innerBoundarySize = innerOffsetSize;

        foreach (Widget widget; children) {
            const widgetFringePosition = vec2(
                widget.position.x + widget.outerSize.x + innerOffset.left,
                widget.position.y + widget.outerSize.y + innerOffset.top
            );

            if (widget.regionAlign != RegionAlign.right &&
                widget.regionAlign != RegionAlign.top &&
                widget.regionAlign != RegionAlign.bottom)
            {
                innerBoundarySize.x = fmax(innerBoundarySize.x, widgetFringePosition.x);
            }

            if (widget.regionAlign != RegionAlign.bottom &&
                widget.regionAlign != RegionAlign.right &&
                widget.regionAlign != RegionAlign.left)
            {
                innerBoundarySize.y = fmax(innerBoundarySize.y, widgetFringePosition.y);
            }
        }

        innerBoundarySize += innerOffsetEnd;

        innerBoundarySizeClamped.x = fmax(innerBoundarySize.x, innerSize.x);
        innerBoundarySizeClamped.y = fmax(innerBoundarySize.y, innerSize.y);
    }

    void onProgress() {
        if (!drawChildren)
            return;

        foreach (Widget widget; children) {
            if (!widget.visible)
                continue;

            widget.onProgress();
        }

        updateBoundary();
    }

    void render(Camera camera) {
        this.camera = camera;

        if (!drawChildren)
            return;

        foreach (Widget widget; children) {
            if (!widget.visible)
                continue;

            widget.render(camera);
        }
    }

    void addWidget(Widget widget) {
        uint index = manager.getNextIndex();
        widget.manager = manager;

        if (children.length == 0) {
            p_firstWidget = widget;
            p_lastWidget = widget;
        }

        // Links
        widget.p_parent = this;
        widget.p_nextWidget = p_firstWidget;
        widget.p_prevWidget = p_lastWidget;

        p_lastWidget.p_nextWidget = widget;
        p_firstWidget.p_prevWidget = widget;
        p_lastWidget = widget;

        // Insert
        children.insert(widget);
        manager.widgetOrdering.insert(widget);
        widget.onCreate();
    }

    bool pointIsEnter(in vec2i point) {
        const Rect rect = Rect(absolutePosition.x, absolutePosition.y, size.x, size.y);
        return pointInRect(point, rect);
    }

    Widget findWidgetByName(in string name) {
        if (this.name == name)
            return this;

        foreach (Widget widget; children) {
            Widget foundWidget = widget.findWidgetByName(name);

            if (foundWidget !is null)
                return foundWidget;
        }

        return null;
    }

    void focus() {
        if (manager.focusedWidget != this && manager.focusedWidget !is null)
            manager.focusedWidget.blur();

        manager.focusedWidget = this;
        p_isFocused = true;

        if (onFocusListener !is null)
            onFocusListener(this);
    }

    void blur() {
        manager.unfocusedWidgets.insert(this);
    }

    void scrollToWidget() {
        Scrollable scrollable = null;
        Widget parent = this.parent;

        while (parent !is null) {
            scrollable = cast(Scrollable) parent;
            parent = parent.p_parent;

            if (scrollable)
                break;
        }

        if (scrollable !is null)
            scrollable.scrollToWidget(this);
    }

    // NOTE: navFocusFront and navFocusBack are symmetrical
    // focusNext and focusPrev too therefore potential code reduction
    protected void navFocusFront() {
        if (skipFocus && firstWidget !is null) {
            firstWidget.navFocusFront();
        } else {
            this.focus();
            this.scrollToWidget();
        }
    }

    void focusNext() {
        if (skipFocus && isFocused) {
            navFocusFront();
            return;
        }

        if (p_parent.p_lastWidget != this) {
            this.p_nextWidget.navFocusFront();
        } else {
            if (p_parent.finalFocus) {
                p_parent.navFocusFront();
            } else {
                p_parent.focusNext();
            }
        }
    }

    protected void navFocusBack() {
        if (skipFocus && lastWidget !is null) {
            lastWidget.navFocusBack();
        } else {
            this.focus();
            this.scrollToWidget();
        }
    }

    void focusPrev() {
        if (skipFocus && isFocused) {
            navFocusBack();
            return;
        }

        if (p_parent.p_firstWidget != this) {
            this.p_prevWidget.navFocusBack();
        } else {
            if (p_parent.finalFocus) {
                p_parent.navFocusBack();
            } else {
                p_parent.focusPrev();
            }
        }
    }

// Events ------------------------------------------------------------------------------------------

    void onCreate() {
    }

    void onKeyPressed(in KeyCode key) {
    }

    void onKeyReleased(in KeyCode key) {
    }

    void onTextEntered(in utfchar key) {
    }

    void onMouseDown(in uint x, in uint y, in MouseButton button) {
        foreach (Widget widget; children) {
            widget.onMouseDown(x, y, button);
        }
    }

    void onMouseUp(in uint x, in uint y, in MouseButton button) {
        foreach (Widget widget; children) {
            widget.onMouseUp(x, y, button);

            if (widget.isEnter)
                widget.triggerClick();
        }
    }

    void onDblClick(in uint x, in uint y, in MouseButton button) {
    }

    void onMouseMove(in uint x, in uint y) {
    }

    void onMouseWheel(in int dx, in int dy) {
        foreach (Widget widget; children) {
            widget.onMouseWheel(dx, dy);
        }
    }

    void onCursor() {
    }

    void onResize() {
        foreach (Widget widget; children) {
            widget.onResize();
        }
    }

protected:
    void updateAlign() {
    }

    void updateVerticalAlign() {
    }

    void updateResize() {
    }

    package void updateAll() {
        updateAbsolutePosition();
        updateRegionAlign();
        updateResize();

        foreach (Widget widget; children) {
            widget.updateAll();
        }

        updateBoundary();
    }

    void updateRegionAlign() {
        if (regionAlign == RegionAlign.none)
            return;

        const FrameRect region = findRegion();
        const vec2 regionSize = vec2(
            parent.innerSize.x - region.right  - region.left - outerOffsetSize.x,
            parent.innerSize.y - region.bottom - region.top  - outerOffsetSize.y
        );

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
                position.y = parent.innerSize.y - outerSize.y - region.bottom;
                break;

            case RegionAlign.left:
                size.y = regionSize.y;
                position = vec2(region.left, region.top);
                break;

            case RegionAlign.right:
                size.y = regionSize.y;
                position.x = parent.innerSize.x - outerSize.x - region.right;
                position.y = region.top;
                break;

            default:
                break;
        }
    }

    FrameRect findRegion() {
        FrameRect region;

        foreach (Widget widget; parent.children) {
            if (widget == this)
                break;

            if (!widget.visible || widget.regionAlign == RegionAlign.none)
                continue;

            switch (widget.regionAlign) {
                case RegionAlign.top:
                    region.top += widget.size.y + widget.outerOffset.bottom;
                    break;

                case RegionAlign.left:
                    region.left += widget.size.x + widget.outerOffset.right;
                    break;

                case RegionAlign.bottom:
                    region.bottom += widget.size.y + widget.outerOffset.top;
                    break;

                case RegionAlign.right:
                    region.right += widget.size.x + widget.outerOffset.left;
                    break;

                default:
                    continue;
            }
        }

        return region;
    }

    @property Renderer renderer() { return manager.renderer; }

package:
    this(Manager manager) {
        this.manager = manager;
        app = Application.getInstance();
    }

    void updateAbsolutePosition() {
        vec2 res = vec2(0, 0);
	Widget lastParent = parent;

        while (lastParent !is null) {
            res += lastParent.position - lastParent.contentOffset;
            res += lastParent.innerOffsetStart + lastParent.outerOffsetStart;
            lastParent = lastParent.parent;
        }

        absolutePosition = position + res + outerOffsetStart;
    }
}

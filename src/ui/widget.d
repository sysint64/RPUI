module ui.widget;

import std.container;
import std.conv;
import std.math;

import input;
import gapi;
import application;
import math.linalg;
import basic_types;

import containers.treemap;

import ui.manager;
import ui.render_factory;
import ui.render_objects;
import ui.cursor;
import ui.renderer;
import ui.scroll;


class Widget {
    alias TreeMap!(uint, Widget) Children;

    // Events aliases
    alias void function(Widget) OnClickListener;
    alias void function(Widget) OnDblClickistener;
    alias void function(Widget) OnFocusListener;
    alias void function(Widget) OnBlurListener;
    alias void function(Widget, in KeyCode key) OnKeyPressedListener;
    alias void function(Widget, in KeyCode key) OnKeyReleasedListener;
    alias void function(Widget, in utfchar key) OnTextEnteredListener;
    alias void function(Widget, in uint x, in uint y) OnMouseMoveListener;
    alias void function(Widget, in uint x, in uint y) OnMouseEnterListener;
    alias void function(Widget, in uint x, in uint y) OnMouseLeaveListener;
    alias void function(Widget, in uint x, in uint y, in MouseButton button) OnMouseDownListener;
    alias void function(Widget, in uint x, in uint y, in MouseButton button) OnMouseUpListener;

    this() {
        app = Application.getInstance();
    }

    this(in string style) {
        app = Application.getInstance();
        this.p_style = style;
    }

    void focus() {
    }

    void blur() {
    }

    void render(Camera camera) {
        this.camera = camera;
        p_innerBoundarySize = vec2(0, 0);

        if (!drawChildren)
            return;

        foreach (uint index, Widget widget; children) {
            if (!widget.visible)
                continue;

            widget.render(camera);

            p_innerBoundarySize.x = fmax(p_innerBoundarySize.x, widget.position.x + widget.size.x);
            p_innerBoundarySize.y = fmax(p_innerBoundarySize.y, widget.position.y + widget.size.y);
        }

        p_innerBoundarySizeClamped.x = fmax(p_innerBoundarySize.x, size.x);
        p_innerBoundarySizeClamped.y = fmax(p_innerBoundarySize.y, size.y);
    }

    void addWidget(Widget widget) {
        uint index = manager.getNextIndex();
        widget.manager = manager;
        widget.p_parent = this;
        children[index] = widget;
        manager.widgetOrdering.insert(widget);
        widget.onCreate();
    }

    bool pointIsEnter(in vec2i point) {
        const Rect rect = Rect(absolutePosition.x, absolutePosition.y, size.x, size.y);
        return pointInRect(point, rect);
    }

    // Events --------------------------------------------------------------------------------------

    void onCreate() {
    }

    void onKeyPressed(in KeyCode key) {
    }

    void onKeyReleased(in KeyCode key) {
    }

    void onTextEntered(in utfchar key) {
    }

    void onMouseDown(in uint x, in uint y, in MouseButton button) {
        foreach (uint index, Widget widget; children) {
            widget.onMouseDown(x, y, button);
        }
    }

    void onMouseUp(in uint x, in uint y, in MouseButton button) {
        foreach (uint index, Widget widget; children) {
            widget.onMouseUp(x, y, button);
        }
    }

    void onDblClick(in uint x, in uint y, in MouseButton button) {
    }

    void onMouseMove(in uint x, in uint y) {
    }

    void onMouseWheel(in int dx, in int dy) {
        foreach (uint index, Widget widget; children) {
            widget.onMouseWheel(dx, dy);
        }
    }

    void onCursor() {
    }

    // Event Listeners ----------------------------------------------------------------------------

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

    // Properties ----------------------------------------------------------------------------------

    bool resizable = false;
    bool withoutSkin = false;
    bool visible = true;
    bool enabled = true;
    vec2 position = vec2(0, 0);
    vec2 size = vec2(0, 0);
    FrameRect margin = FrameRect(0, 0, 0, 0);
    FrameRect padding = FrameRect(0, 0, 0, 0);
    bool autoWidth;
    bool autoHeight;
    Cursor.Icon cursor;
    string name = "";
    int tag = 0;
    utfstring hint = "";
    Align locationAlign = Align.none;
    VerticalAlign locationVerticalAlign = VerticalAlign.none;
    RegionAlign regionAlign = RegionAlign.none;

    @property {
        uint id() { return p_id; }
        Widget parent() { return p_parent; }

        bool focused() { return p_focused; }
        string style() { return p_style; }

        vec2 absolutePosition() { return p_absolutePosition; }

        vec2 innerBoundarySize() { return p_innerBoundarySize; }
        vec2 innerBoundarySizeClamped() { return p_innerBoundarySizeClamped; }

        ref Children children() { return p_children; }

        bool isEnter() { return p_isEnter; }
        bool isClick() { return p_isClick; }
        bool isOver()  { return p_isOver; }
        bool overlay() { return p_overlay; }

        string state() {
            if (isClick) {
                return "Click";
            } else if (isEnter) {
                return "Enter";
            } else {
                return "Leave";
            }
        }

        RenderFactory renderFactory() { return manager.renderFactory; }
    }

protected:
    enum PartDraws {all, left, center, right};

    Application app;
    Manager manager;

    void updateAlign() {
    }

    void updateVerticalAlign() {
    }

    void updateRegionAlign() {
    }

    @property Renderer renderer() { return manager.renderer; }

package:
    bool drawChildren = true;
    FrameRect regionOffset = FrameRect(0, 0, 0, 0);

    this(Manager manager) {
        this.manager = manager;
        app = Application.getInstance();
    }

    void updateAbsolutePosition() {
        vec2 res = vec2(0, 0);
	Widget lastParent = parent;

        while (lastParent !is null) {
            res.x += lastParent.position.x - lastParent.contentOffset.x + lastParent.padding.left +
                lastParent.margin.left;

            res.y += lastParent.position.y - lastParent.contentOffset.y + lastParent.padding.top +
                lastParent.margin.top;

            lastParent = lastParent.parent;
        }

        p_absolutePosition.x = position.x + res.x + margin.left;
        p_absolutePosition.y = position.y + res.y + margin.top;
    }

    vec2 contentOffset = vec2(0, 0);

    @property void isEnter(in bool val) { p_isEnter = val; }
    @property void isClick(in bool val) { p_isClick = val; }
    @property void isOver(in bool val) { p_isOver = val; }
    @property vec2 overSize() { return p_overSize; }

private:
    Camera camera = null;

    // Navigation (for focus)
    Widget nextWidget = null;
    Widget prevWidget = null;
    Widget lastWidget = null;
    Widget firstWidget = null;

    // Properties data
    uint p_id;
    Widget p_parent;

    vec2 p_absolutePosition;
    vec2 p_overSize = vec2(0, 0);

    Children p_children;
    bool p_focused = false;
    bool p_overlay = false;
    string p_style = "";
    PartDraws p_partDraws = PartDraws.all;
    bool p_isEnter = false;
    bool p_isClick = false;
    bool p_isOver = false;  // When in rect of element but if another element over this
                            // isOver will still be true

    vec2 p_innerBoundarySize = vec2(0, 0);
    vec2 p_innerBoundarySizeClamped = vec2(0, 0);
}

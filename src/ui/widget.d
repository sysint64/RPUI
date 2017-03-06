module ui.widget;

import std.container;
import std.conv;

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

        if (!drawChildren)
            return;

        foreach (uint index, Widget widget; children) {
            if (!widget.visible)
                continue;

            widget.render(camera);
        }
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
    }

    void onCursor() {
    }

    // Properties ----------------------------------------------------------------------------------

    @property uint id() { return p_id; }
    @property Widget parent() { return p_parent; }

    @property bool focused() { return p_focused; }
    @property string style() { return p_style; }

    @property Cursor.Icon cursor() { return p_cursor; }
    @property void cursor(in Cursor.Icon val) { p_cursor = val; }

    @property ref bool withoutSkin() { return p_withoutSkin; }
    @property void withoutSkin(in bool val) { p_withoutSkin = val; }

    @property ref bool visible() { return p_visible; }
    @property void visible(in bool val) { p_visible = val; }

    @property ref bool enabled() { return p_enabled; }
    @property void enabled(in bool val) { p_enabled = val; }

    @property ref vec2 position() { return p_position; }
    @property void position(in vec2 val) { p_position = val; }

    @property vec2 absolutePosition() { return p_absolutePosition; }
    @property vec2 scroll() { return p_scroll; }

    @property ref vec2 size() { return p_size; }
    @property void size(in vec2 val) { p_size = val; }

    @property ref FrameRect margin() { return p_margin; }
    @property void margin(in vec4 val) { p_margin = FrameRect(val); }
    @property void margin(in FrameRect val) { p_margin = val; }

    @property ref FrameRect padding() { return p_padding; }
    @property void padding(in vec4 val) { p_padding = FrameRect(val); }
    @property void padding(in FrameRect val) { p_padding = val; }

    @property ref bool autoWidth() { return p_autoWidth; }
    @property void autoWidth(in bool val) { p_autoWidth = val; }

    @property ref bool autoHeight() { return p_autoHeight; }
    @property void autoHeight(in bool val) { p_autoHeight = val; }

    @property ref Children children() { return p_children; }

    @property bool isEnter() { return p_isEnter; }
    @property bool isClick() { return p_isClick; }
    @property bool isOver() { return p_isOver; }
    @property bool overlay() { return p_overlay; }

    @property string state() {
        if (isClick) {
            return "Click";
        } else if (isEnter) {
            return "Enter";
        } else {
            return "Leave";
        }
    }

    @property RenderFactory renderFactory() { return manager.renderFactory; }
    @property Align locationAlign() { return p_locationAlign; }
    @property VerticalAlign locationVerticalAlign() { return p_locationVerticalAlign; }

    @property RegionAlign regionAlign() { return p_regionAlign; }
    @property void regionAlign(in RegionAlign val) { p_regionAlign = val; }

    @property ref bool resizable() { return p_resizable; }
    @property void resizable(in bool val) { p_resizable = val; }

    // Event Listeners
    @property void onClickListener(in OnClickListener val) { p_onClickListener = val; }
    @property void onDblClickistener(in OnDblClickistener val) { p_onDblClickistener = val; }
    @property void onFocusListener(in OnFocusListener val) { p_onFocusListener = val; }
    @property void onBlurListener(in OnBlurListener val) { p_onBlurListener = val; }
    @property void onKeyPressedListener(in OnKeyPressedListener val) { p_onKeyPressedListener = val; }
    @property void onTextEnteredListener(in OnTextEnteredListener val) { p_onTextEnteredListener = val; }
    @property void onMouseEnterListener(in OnMouseEnterListener val) { p_onMouseEnterListener = val; }
    @property void onMouseLeaveListener(in OnMouseLeaveListener val) { p_onMouseLeaveListener = val; }
    @property void onMouseDownListener(in OnMouseDownListener val) { p_onMouseDownListener = val; }
    @property void onMouseUpListener(in OnMouseUpListener val) { p_onMouseUpListener = val; }

protected:
    enum PartDraws {all, left, center, right};

    Application app;
    Manager manager;

    void updateAlign() {
    }

    void updateVerticalAlign() {
    }

    float offsetSizeX() {
        return 0;
    }

    float offsetSizeY() {
        return 0;
    }

    FrameRect regionOffset() {
        return FrameRect(0, 0, 0, 0);
    }

    @property Renderer renderer() { return manager.renderer; }

package:
    bool drawChildren = true;

    this(Manager manager) {
        this.manager = manager;
        app = Application.getInstance();
    }

    void updateAbsolutePosition() {
        vec2 res = vec2(0, 0);
	Widget lastParent = parent;

        while (lastParent !is null) {
            res.x += lastParent.position.x - lastParent.scroll.x + lastParent.padding.left +
                lastParent.margin.left;

            res.y += lastParent.position.y - lastParent.scroll.y + lastParent.padding.top +
                lastParent.margin.top;

            lastParent = lastParent.parent;
        }

        p_absolutePosition.x = position.x + res.x + margin.left;
        p_absolutePosition.y = position.y + res.y + margin.top;
    }

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

    vec2 p_position = vec2(0, 0);
    vec2 p_absolutePosition;
    vec2 p_size = vec2(0, 0);
    vec2 p_overSize = vec2(0, 0);
    vec2 p_scroll = vec2(0, 0);
    FrameRect p_margin = FrameRect(0, 0, 0, 0);
    FrameRect p_padding = FrameRect(0, 0, 0, 0);

    Children p_children;
    bool p_focused = false;
    bool p_withoutSkin = false;
    bool p_visible = true;
    bool p_enabled = true;
    bool p_overlay = false;
    string p_style = "";
    string p_name = "";
    int p_tag = -1;
    utfstring p_hint = "";
    Cursor.Icon p_cursor;
    PartDraws p_partDraws = PartDraws.all;
    Align p_locationAlign = Align.none;
    VerticalAlign p_locationVerticalAlign = VerticalAlign.none;
    RegionAlign p_regionAlign = RegionAlign.none;
    bool p_isEnter = false;
    bool p_isClick = false;
    bool p_isOver = false;  // When in rect of element but if another element over this
                            // isOver will still be true
    VerticalAlign p_verticalAlign = VerticalAlign.none;
    bool p_autoWidth = false;
    bool p_autoHeight = false;
    bool p_resizable = true;

    // Event Listeners
    OnClickListener p_onClickListener = null;
    OnDblClickistener p_onDblClickistener = null;
    OnFocusListener p_onFocusListener = null;
    OnBlurListener p_onBlurListener = null;
    OnKeyPressedListener p_onKeyPressedListener = null;
    OnKeyReleasedListener p_onKeyReleasedListener = null;
    OnTextEnteredListener p_onTextEnteredListener = null;
    OnMouseMoveListener p_onMouseMoveListener = null;
    OnMouseEnterListener p_onMouseEnterListener = null;
    OnMouseLeaveListener p_onMouseLeaveListener = null;
    OnMouseDownListener p_onMouseDownListener = null;
    OnMouseUpListener p_onMouseUpListener = null;
}

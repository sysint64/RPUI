module ui.widget;

import std.container;
import std.conv;

import input;
import gapi;
import application;
import math.linalg;

import ui.manager;
import ui.precompute.helper_methods;
import ui.render_helper_methods;
import ui.cursor;


enum Align {
    none,
    left,
    center,
    right,
    client,
};

enum VerticalAlign {
    none,
    top,
    middle,
    bottom,
    client,
}

class Widget {
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

    this(Manager manager) {
        this.manager = manager;
    }

    void focus() {
    }

    void blur() {
    }

    void render() {
    }

    // Properties
    @property uint id() { return p_id; }

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

    @property ref vec2i position() { return p_position; }
    @property void position(in vec2i val) { p_position = val; }

    @property vec2i absolutePosition() { return p_absolutePosition; }

    @property ref vec2i size() { return p_size; }
    @property void size(in vec2i val) { p_size = val; }

    @property ref vec4i margin() { return p_margin; }
    @property void margin(in vec4i val) { p_margin = val; }

    @property ref vec4i padding() { return p_padding; }
    @property void padding(in vec4i val) { p_padding = val; }

    @property ref bool autoWidth() { return p_autoWidth; }
    @property void autoWidth(in bool val) { p_autoWidth = val; }

    @property ref bool autoHeight() { return p_autoHeight; }
    @property void autoHeight(in bool val) { p_autoHeight = val; }

    @property Widget[uint] children() { return p_children; }

    @property bool isEnter() { return p_isEnter; }
    @property bool isClick() { return p_isClick; }
    @property bool isOver() { return p_isOver; }


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
    struct PrecomputeCoords {
        vec2 normOffset;  // normalized by 1 offset
        vec2 normSize;  // normalized by 1 size
        vec2i offset;
        vec2i size;
    }

    struct PrecomputeText {
        vec4 color;
        vec2i offset;
    }

    Application app;
    Manager manager;
    Widget parent;

    void updateAlign() {
    }

    void updateVerticalAlign() {
    }

    void updateAbsolutePosition() {
    }

    void precompute() {
    }

    mixin PrecomputeHelperMethods;
    mixin RenderHelperMethods;

private:
    PrecomputeCoords[32] precomputeCoords;
    PrecomputeText[32] precomputeTexts;

    // Navigation (for focus)
    Widget nextWidget = null;
    Widget prevWidget = null;
    Widget lastWidget = null;
    Widget firstWidget = null;

    // Properties data
    uint p_id;

    vec2i p_position;
    vec2i p_absolutePosition;
    vec2i p_size;
    vec4i p_margin;
    vec4i p_padding;

    Widget[uint] p_children;
    bool p_focused = false;
    bool p_withoutSkin = false;
    bool p_visible = true;
    bool p_enabled = true;
    string p_style = "";
    string p_name = "";
    int p_tag = -1;
    utfstring p_hint = "";
    Cursor.Icon p_cursor;
    PartDraws p_partDraws = PartDraws.all;
    Align p_align = Align.none;
    bool p_isEnter = false;
    bool p_isClick = false;
    bool p_isOver = false;  // When in rect of element but if another element over this
                            // isOver will still be true
    VerticalAlign p_verticalAlign = VerticalAlign.none;
    bool p_autoWidth = false;
    bool p_autoHeight = false;

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

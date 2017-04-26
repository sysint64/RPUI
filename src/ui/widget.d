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
    struct Field {
        string name = "";
    }

    alias TreeMap!(uint, Widget) Children;

// Properties --------------------------------------------------------------------------------------

    @Field bool resizable = true;  // ???
    @Field bool withoutSkin = false;
    @Field bool visible = true;
    @Field bool enabled = true;
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
    @property bool focused() { return p_focused; }

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

// Event Listeners ---------------------------------------------------------------------------------

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

// Implementation ----------------------------------------------------------------------------------

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

    void onProgress() {
        if (!drawChildren)
            return;

        innerBoundarySize = vec2(0, 0);

        foreach (uint index, Widget widget; children) {
            if (!widget.visible)
                continue;

            widget.onProgress();

            innerBoundarySize.x = fmax(innerBoundarySize.x, widget.position.x + widget.size.x);
            innerBoundarySize.y = fmax(innerBoundarySize.y, widget.position.y + widget.size.y);
        }

        innerBoundarySize.x += padding.left + padding.right + regionOffset.left + regionOffset.right;
        innerBoundarySize.y += padding.top + padding.bottom + regionOffset.top + regionOffset.bottom;

        innerBoundarySizeClamped.x = fmax(innerBoundarySize.x, size.x);
        innerBoundarySizeClamped.y = fmax(innerBoundarySize.y, size.y);
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

    Widget findWidgetByName(in string name) {
        if (this.name == name)
            return this;

        foreach (uint index, Widget widget; children) {
            Widget foundWidget = widget.findWidgetByName(name);

            if (foundWidget !is null)
                return foundWidget;
        }

        return null;
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

private:
    Children p_children;

    uint p_id;
    string p_style;
    Widget p_parent;
    bool p_focused;

    Camera camera = null;

    // Navigation (for focus)
    Widget nextWidget = null;
    Widget prevWidget = null;
    Widget lastWidget = null;
    Widget firstWidget = null;

protected:
    enum PartDraws {all, left, center, right};

    Application app;
    Manager manager;
    PartDraws partDraws;

    void updateAlign() {
    }

    void updateVerticalAlign() {
    }

    void updateRegionAlign() {
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

    @property Renderer renderer() { return manager.renderer; }

package:
    bool drawChildren = true;
    FrameRect regionOffset = FrameRect(0, 0, 0, 0);
    bool overlay;
    vec2 overSize;
    bool isEnter;
    bool isClick;
    bool isOver;  // When in rect of element but if another element over this
                  // isOver will still be true

    vec2 absolutePosition = vec2(0, 0);
    vec2 innerBoundarySizeClamped = vec2(0, 0);
    vec2 innerBoundarySize = vec2(0, 0);

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

        absolutePosition.x = position.x + res.x + margin.left;
        absolutePosition.y = position.y + res.y + margin.top;
    }

    vec2 contentOffset = vec2(0, 0);
}

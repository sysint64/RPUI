/**
 * Copyright: © 2017 Andrey Kabylin
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 */

module rpui.widget;

import std.container;
import std.conv;
import std.math;
import std.functional;
import std.algorithm;

import input;
import gapi;
import application;
import math.linalg;
import basic_types;

import rpui.manager;
import rpui.render_factory;
import rpui.render_objects;
import rpui.cursor;
import rpui.renderer;
import rpui.scroll;
import rpui.widget_events;
import rpui.widget_locator;
import rpui.focus_navigator;
import rpui.widgets_container;
import rpui.widget_resolver;
import rpui.events;

/// Interface for scrollable widgets.
interface Scrollable {
    void onMouseWheelHandle(in int dx, in int dy);

    void scrollToWidget(Widget widget);
}

/// For scrollable widgets and if this widget allow to focus elements.
interface FocusScrollNavigation : Scrollable {
    /**
     * Scroll to widget if it out of visible region.
     * Scroll on top border if widget above and bottom if below visible region.
     */
    void borderScrollToWidget(Widget widget);
}

class Widget : EventsListenerEmpty {
    /// Type of sizing for width and height.
    enum SizeType {
        value,  /// Using value from size.
        wrapContent,  /// Automatically resize widget by content boundary.
        matchParent  /// Using parent size.
    }

    /**
     * Field attribute need to tell RPDL which fields are fill
     * when reading layout file.
     */
    struct Field {
        string name = "";  /// Override name of variable.
    }

// Properties --------------------------------------------------------------------------------------

    @Field bool visible = true;
    @Field bool enabled = true;
    @Field bool focusable = true;

    /// If true, then focus navigation by children will be limited inside this widget.
    @Field bool finalFocus = false;

    /// Specifies the type of cursor to be displayed when pointing on an element.
    @Field Cursor.Icon cursor = Cursor.Icon.normal;

    @Field string name = "";

    /// Some help information about widget, need to display tooltip.
    @Field utf32string hint = "";

    /// How to place a widget horizontally.
    @Field Align locationAlign = Align.none;

    /// How to place a widget vertically.
    @Field VerticalAlign verticalLocationAlign = VerticalAlign.none;

    /**
     * If set this option then widget will be pinned to one of the side
     * declared in the `basic_types.RegionAlign`.
     */
    @Field RegionAlign regionAlign = RegionAlign.none;

    /// Used to create space around elements, outside of any defined borders.
    @Field FrameRect margin = FrameRect(0, 0, 0, 0);

    /// Used to generate space around an element's content, inside of any defined borders.
    @Field FrameRect padding = FrameRect(0, 0, 0, 0);

    @Field vec2 position = vec2(0, 0);
    @Field vec2 size = vec2(0, 0);

    @Field SizeType widthType;  /// Determine how to set width for widget.
    @Field SizeType heightType;  /// Determine how to set height for widget.

    @Field
    @property float width() { return size.x; }
    @property void width(in float val) { size.x = val; }

    @Field
    @property float height() { return size.y; }
    @property void height(in float val) { size.y = val; }

    @property size_t id() { return p_id; }
    private size_t p_id;

    /// Widget root rpdl node from where the data will be extracted.
    const string style;

    @property Widget parent() { return p_parent; }
    package Widget p_parent;

    package Widget owner;

    @property bool isFocused() { return p_isFocused; }

    /// Next widget in `parent` children after this.
    @property Widget nextWidget() { return p_nextWidget; }
    package Widget p_nextWidget = null;

    /// Previous widget in `parent` children before this.
    @property Widget prevWidget() { return p_prevWidget; }
    package Widget p_prevWidget = null;

    /// Last widget in `parent` children.
    @property Widget lastWidget() { return p_lastWidget; }
    package Widget p_lastWidget = null;

    /// First widget in `parent` children.
    @property Widget firstWidget() { return p_firstWidget; }
    package Widget p_firstWidget = null;

    @property ref WidgetsContainer children() { return p_children; }
    private WidgetsContainer p_children;

    @property uint depth() { return p_depth; }
    uint p_depth = 0;

    @property WidgetResolver resolver() { return p_resolver; }
    private WidgetResolver p_resolver;

    @property FocusNavigator focusNavigator() { return p_focusNavigator; }
    private FocusNavigator p_focusNavigator;

    @property WidgetEventsObserver events() { return p_events; }
    private WidgetEventsObserver p_events;

    /// Additional rules appart from `visible` to set widget visible or not.
    Array!(bool delegate()) visibleRules;

    /// Additional rules appart from `enabled` to set widget enabled or not.
    Array!(bool delegate()) enableRules;

protected:
    /**
     * Which part of widget need to render, e.g. if it is a button
     * then `PartDraws.left` tell that only left side and center will be
     * rendered, this need for grouping rendering of widgets.
     *
     * As example consider this layout of grouping: $(I [button1|button2|button3|button4])
     *
     * for $(I button1) `PartDraws` will be $(B left), for $(I button2) and $(I button3) $(B center)
     * and for $(I button4) it will be $(B right).
     */
    enum PartDraws {
        all,  /// Draw all parts - left, center and right.
        left,
        center,
        right
    }

    package Application app;
    PartDraws partDraws;

package:
    Manager manager;
    bool p_isFocused;
    bool skipFocus = false;  /// Don't focus this element.
    bool drawChildren = true;
    FrameRect extraInnerOffset = FrameRect(0, 0, 0, 0);  /// Extra inner offset besides padding.
    FrameRect extraOuterOffset = FrameRect(0, 0, 0, 0);  /// Extra outer offset besides margin.
    bool overlay;
    vec2 overSize;
    Rect overlayRect = emptyRect;
    bool focusOnMousUp = false;

    bool isEnter;  /// True if pointed on widget.
    bool overrideIsEnter;  /// Override isEnter state i.e. ignore isEnter value and use overrided value.
    bool isClick;
    bool isMouseDown = false;

    WidgetLocator locator;

    /**
     * When in rect of element but if another element over this
     * isOver will still be true.
     */
    bool isOver;

    vec2 absolutePosition = vec2(0, 0);

    /// Size of boundary over childern clamped to size of widget as minimum boundary size.
    vec2 innerBoundarySizeClamped = vec2(0, 0);

    vec2 innerBoundarySize = vec2(0, 0);  /// Size of boundary over childern.
    vec2 contentOffset = vec2(0, 0);  /// Children offset relative their absolute positions.
    vec2 outerBoundarySize = vec2(0, 0); /// Full region size including inner offsets.

    Widget associatedWidget = null;

    @property Renderer renderer() { return manager.renderer; }
    @property RenderFactory renderFactory() { return manager.renderFactory; }

    /**
     * Returns string of state declared in theme.
     */
    @property inout(string) state() inout {
        if (isClick) {
            return "Click";
        } else if (isEnter || overrideIsEnter) {
            return "Enter";
        } else {
            return "Leave";
        }
    }

    /// Inner size considering the extra innter offsets and paddings.
    @property vec2 innerSize() {
        return size - innerOffsetSize;
    }

    /// Total inner offset size (width and height) considering the extra inner offsets and paddings.
    @property vec2 innerOffsetSize() {
        return vec2(
            padding.left + padding.right + extraInnerOffset.left + extraInnerOffset.right,
            padding.top + padding.bottom + extraInnerOffset.top + extraInnerOffset.bottom
        );
    }

    /// Inner padding plus and extra inner offsets.
    @property FrameRect innerOffset() {
        return FrameRect(
            padding.left + extraInnerOffset.left,
            padding.top + extraInnerOffset.top,
            padding.right + extraInnerOffset.right,
            padding.bottom + extraInnerOffset.bottom,
        );
    }

    /// Total size of extra inner offset (width and height).
    @property vec2 extraInnerOffsetSize() {
        return vec2(
            extraInnerOffset.left + extraInnerOffset.right,
            extraInnerOffset.top + extraInnerOffset.bottom
        );
    }

    @property vec2 extraInnerOffsetStart() {
        return vec2(extraInnerOffset.left, extraInnerOffset.top);
    }

    @property vec2 extraInnerOffsetEnd() {
        return vec2(extraInnerOffset.right, extraInnerOffset.bottom);
    }

    @property vec2 innerOffsetStart() {
        return vec2(innerOffset.left, innerOffset.top);
    }

    @property vec2 innerOffsetEnd() {
        return vec2(innerOffset.right, innerOffset.bottom);
    }

    /// Outer size considering the extra outer offsets and margins.
    @property vec2 outerSize() {
        return size + outerOffsetSize;
    }

    /// Total outer offset size (width and height) considering the extra outer offsets and margins.
    @property vec2 outerOffsetSize() {
        return vec2(
            margin.left + margin.right + extraOuterOffset.left + extraOuterOffset.right,
            margin.top + margin.bottom + extraOuterOffset.top + extraOuterOffset.bottom
        );
    }

    /// Total outer offset - margins plus extra outer offsets.
    @property FrameRect outerOffset() {
        return FrameRect(
            margin.left + extraOuterOffset.left,
            margin.top + extraOuterOffset.top,
            margin.right + extraOuterOffset.right,
            margin.bottom + extraOuterOffset.bottom,
        );
    }

    @property vec2 outerOffsetStart() {
        return vec2(outerOffset.left, outerOffset.top);
    }

    @property vec2 outerOffsetEnd() {
        return vec2(outerOffset.right, outerOffset.bottom);
    }

public:
    /// Default constructor with default `style`.
    this() {
        this.app = Application.getInstance();
        this.style = "";
        createComponents();
    }

    /// Construct with custom `style`.
    this(in string style) {
        this.app = Application.getInstance();
        this.style = style;
        createComponents();
    }

    package this(Manager manager) {
        this.app = Application.getInstance();
        this.style = "";
        this.manager = manager;
        createComponents();
    }

    private void createComponents() {
        this.locator = new WidgetLocator(this);
        this.p_focusNavigator = new FocusNavigator(this);
        this.p_children = new WidgetsContainer(this);
        this.p_resolver = new WidgetResolver(this);
        this.p_events = new WidgetEventsObserver();

        this.p_events.subscribe!BlurEvent(&onBlur);
        this.p_events.subscribe!FocusEvent(&onFocus);
    }

    /// Update widget inner bounary and clamped boundary.
    protected void updateBoundary() {
        if (!drawChildren)
            return;

        innerBoundarySize = innerOffsetSize;

        foreach (Widget widget; children) {
            auto widgetFringePosition = vec2(
                widget.position.x + widget.outerSize.x + innerOffset.left,
                widget.position.y + widget.outerSize.y + innerOffset.top
            );

            if (widget.locationAlign != Align.none) {
                widgetFringePosition.x = 0;
            }

            if (widget.verticalLocationAlign != VerticalAlign.none) {
                widgetFringePosition.y = 0;
            }

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

    void progress() {
        checkRules();

        if (!drawChildren)
            return;

        foreach (Widget widget; children) {
            if (!widget.visible && !widget.processPorgress())
                continue;

            widget.progress();
        }

        updateBoundary();
    }

    package bool processPorgress() {
        return !visibleRules.empty || !enableRules.empty;
    }

    void checkRules() {
        if (!visibleRules.empty) {
            visible = true;

            foreach (bool delegate() rule; visibleRules) {
                visible = visible && rule();
            }
        }

        if (!enableRules.empty) {
            enabled = true;

            foreach (bool delegate() rule; enableRules) {
                enabled = enabled && rule();
            }
        }
    }

    /// Render widget in camera view.
    void render(Camera camera) {
        if (!drawChildren)
            return;

        foreach (Widget widget; children) {
            if (!widget.visible)
                continue;

            widget.render(camera);
        }
    }

    /// Determine if `point` is inside widget area.
    bool pointIsEnter(in vec2i point) {
        const Rect rect = Rect(absolutePosition.x, absolutePosition.y, size.x, size.y);
        return pointInRect(point, rect);
    }

    /// Make focus for widget, and clear focus from focused widget.
    void focus() {
        if (!focusable)
            return;

        events.notify(FocusEvent());

        if (manager.focusedWidget != this && manager.focusedWidget !is null)
            manager.focusedWidget.blur();

        manager.focusedWidget = this;
        p_isFocused = true;

        if (!this.skipFocus)
            focusNavigator.borderScrollToWidget();
    }

    /// Clear focus from widget
    void blur() {
        isClick = false;
        p_isFocused = false;
        manager.unfocusedWidgets.insert(this);
    }

    void onCreate() {
    }

    void onPostCreate() {
        foreach (Widget widget; children) {
            widget.onPostCreate();
        }
    }

    override void onMouseMove(in MouseMoveEvent event) {
        isClick = isEnter && isMouseDown;
    }

    override void onMouseUp(in MouseUpEvent event) {
        if ((isFocused && isEnter) || (!focusable && isEnter))
            events.notify(ClickEvent());
    }

    void onFocus(in FocusEvent event) {}

    void onBlur(in BlurEvent event) {}

    /// Override this method if need change behaviour when system cursor have to be changed.
    void onCursor() {
    }

    void onResize() {
    }

    void onClickActionInvoked() {
    }

package:
    /// This method invokes when widget size is updated.
    public void updateSize() {
        if (widthType == SizeType.matchParent) {
            locationAlign = Align.none;
            size.x = parent.innerSize.x - outerOffsetSize.x;
            position.x = 0;
        }

        if (heightType == SizeType.matchParent) {
            verticalLocationAlign = VerticalAlign.none;
            size.y = parent.innerSize.y - outerOffsetSize.y;
            position.y = 0;
        }
    }

    /// Recalculate size and position of widget and children widgets.
    void updateAll() {
        locator.updateAbsolutePosition();
        locator.updateLocationAlign();
        locator.updateVerticalLocationAlign();
        locator.updateRegionAlign();
        updateSize();

        foreach (Widget widget; children) {
            widget.updateAll();
        }

        updateBoundary();
        updateSize();
    }

    void freezeUI(bool isNestedFreeze = true) {
        manager.freezeUI(this, isNestedFreeze);
    }

    void unfreezeUI() {
        manager.unfreezeUI(this);
    }

    bool isFrozen() {
        return manager.isWidgetFrozen(this);
    }

    bool isFreezingSource() {
        return manager.isWidgetFreezingSource(this);
    }
}

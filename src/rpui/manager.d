/**
 * Manager of all UI elements.
 *
 * Copyright: © 2017 Andrey Kabylin
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 */

module rpui.manager;

import std.container;
import std.container.array;

import input;
import application;
import math.linalg;
import basic_types;

import resources.strings;
import resources.images;
import resources.icons;
import resources.shaders;

import opengl;
import gapi.camera;

import rpui.theme;
import rpui.scroll;
import rpui.widget;
import rpui.cursor;
import rpui.render_factory;
import rpui.renderer;
import rpui.events;
import rpui.events_observer;
import rpui.widget_events;

/**
 * Manager of all widgets.
 */
class Manager : EventsListenerEmpty {
    StringsRes stringsRes;  /// String resources for internationalization.
    ImagesRes imagesRes;  /// Image resources.
    IconsRes iconsRes;  /// Icons resources.
    ShadersRes shadersRes;
    EventsObserver events;

    private Widget p_widgetUnderMouse = null;
    @property Widget widgetUnderMouse() { return p_widgetUnderMouse; }

    private this() {
        app = Application.getInstance();
        unfocusedWidgets.reserve(20);
        events = new EventsObserver();
    }

    private Subscriber rootWidgetSubscriber;

    /// Creating manager with particular theme.
    this(in string themeName) {
        app = Application.getInstance();

        with (rootWidget = new Widget(this)) {
            isOver = true;
            finalFocus = true;
            size.x = this.app.windowWidth;
            size.y = this.app.windowHeight;
        }

        events = new EventsObserver();
        events.join(rootWidget.events);
        // rootWidgetSubscriber = rootWidget.events.subscribe(rootWidget);

        this.imagesRes = new ImagesRes(app.pathes, themeName);
        this.iconsRes = new IconsRes(app.pathes, this.imagesRes);
        this.shadersRes = new ShadersRes();

        this.theme = new Theme(themeName);
        this.renderFactory = new RenderFactory(this);
        this.renderer = new Renderer(this);

        unfocusedWidgets.reserve(20);
    }

    /// Invokes all `onProgress` of all widgets and `poll` widgets.
    void onProgress() {
        cursor = Cursor.Icon.inherit;
        rootWidget.progress();
        poll();
        blur();

        // NOTE: If progress will lag or get incorrect data, we can just
        // add additional foreach traverse, for resolve update due-to
        // some other widget values dependenciec.
        foreach_reverse (Widget widget; frontWidgets) {
            if (!widget.visible && !widget.processPorgress())
                continue;

            widget.progress();

            if (widget.isOver)
                cursor = Cursor.Icon.inherit;
        }

        app.setCursor(cursor);
    }

    /// Renders all widgets inside `camera` view.
    void render(Camera camera) {
        rootWidget.size.x = app.windowWidth;
        rootWidget.size.y = app.windowHeight;

        renderer.camera = camera;
        rootWidget.render(camera);

        foreach (Widget widget; frontWidgets) {
            if (widget.visible)
                widget.render(camera);
        }
    }

    /**
     * Determines widgets states - check when widget `isEnter` (i.e. mouse inside widget area);
     * `isClick` (when user clicked to widget) and when widget is over i.e. mouse inside widget area
     * but widget can be overlapped by another widget.
     */
    private void poll() {
        rootWidget.isOver = true;
        auto widgetsOrderingChain = widgetOrdering ~ frontWidgetsOrdering;

        foreach (Widget widget; widgetsOrderingChain) {
            if (widget is null)
                continue;

            if (!widget.visible) {
                widget.isOver = false;
                widget.isEnter = false;
                widget.isClick = false;
                continue;
            }

            if (!isWidgetFrozen(widget))
                widget.onCursor();

            widget.isEnter = false;

            const size = vec2(
                widget.overSize.x > 0 ? widget.overSize.x : widget.size.x,
                widget.overSize.y > 0 ? widget.overSize.y : widget.size.y
            );

            Rect rect;

            if (widget.overlayRect == emptyRect) {
                rect = Rect(widget.absolutePosition, size);
            } else {
                rect = widget.overlayRect;
            }

            widget.isOver = widget.parent.isOver && pointInRect(app.mousePos, rect);
        }

        p_widgetUnderMouse = null;
        Widget found = null;

        foreach_reverse (Widget widget; widgetsOrderingChain) {
            if (found !is null && !widget.overlay)
                continue;

            if (widget is null || !widget.isOver || !widget.visible)
                continue;

            if (isWidgetFrozen(widget))
                continue;

            if (found !is null) {
                found.isEnter = false;
                found.isClick = false;
            }

            if (widget.pointIsEnter(app.mousePos)) {
                widget.isEnter = true;
                p_widgetUnderMouse = widget;
                found = widget;

                if (cursor == Cursor.Icon.inherit) {
                    cursor = widget.cursor;
                }

                break;
            }
        }
    }

    /// Add `widget` to root children.
    void addWidget(Widget widget) {
        rootWidget.children.addWidget(widget);
    }

    /// Delete `widget` from root children.
    void deleteWidget(Widget widget) {
        rootWidget.children.deleteWidget(widget);
    }

    /// Delete widget by `id` from root children.
    void deleteWidget(in size_t id) {
        rootWidget.children.deleteWidget(id);
    }

    /// Push scissor to stack.
    package void pushScissor(in Rect scissor) {
        if (scissorStack.length == 0)
            glEnable(GL_SCISSOR_TEST);

        scissorStack.insertBack(scissor);
        applyScissor();
    }

    /// Pop scissor from stack.
    package void popScissor() {
        scissorStack.removeBack(1);

        if (scissorStack.length == 0) {
            glDisable(GL_SCISSOR_TEST);
        } else {
            applyScissor();
        }
    }

    /// Apply all scissors for clipping widgets in scissors areas.
    Rect applyScissor() {
        FrameRect currentScissor = scissorStack.back.absolute;

        if (scissorStack.length >= 2) {
            foreach (Rect scissor; scissorStack) {
                if (currentScissor.left < scissor.absolute.left)
                    currentScissor.left = scissor.absolute.left;

                if (currentScissor.top < scissor.absolute.top)
                    currentScissor.top = scissor.absolute.top;

                if (currentScissor.right > scissor.absolute.right)
                    currentScissor.right = scissor.absolute.right;

                if (currentScissor.bottom > scissor.absolute.bottom)
                    currentScissor.bottom = scissor.absolute.bottom;
            }
        }

        auto screenScissor = IntRect(currentScissor);
        screenScissor.top = app.windowHeight - screenScissor.top - screenScissor.height;
        glScissor(screenScissor.left, screenScissor.top, screenScissor.width, screenScissor.height);

        return Rect(currentScissor);
    }

    /// Focusing next widget after the current focused widget.
    void focusNext() {
        if (focusedWidget !is null)
            focusedWidget.focusNavigator.focusNext();
    }

    /// Focusing previous widget before the current focused widget.
    void focusPrev() {
        if (focusedWidget !is null)
            focusedWidget.focusNavigator.focusPrev();
    }

// Events ------------------------------------------------------------------------------------------

    /**
     * Root widget to handle all events such as `onKeyPressed`, `onKeyReleased` etc.
     * Default is `rootWidget` but if UI was freeze by some widget (e.g. dialog window)
     * then source will be top of freeze sources stack.
     */
    @property
    private Widget eventRootWidget() {
        return freezeSources.empty ? rootWidget : freezeSources.front;
    }

    override void onKeyPressed(in KeyPressedEvent event) {
        if (focusedWidget !is null && isClickKey(event.key)) {
            focusedWidget.isClick = true;
        }
    }

    override void onKeyReleased(in KeyReleasedEvent event) {
        if (focusedWidget !is null && isClickKey(event.key)) {
            focusedWidget.isClick = false;
            focusedWidget.onClickActionInvoked();
            focusedWidget.events.notify(ClickEvent());
            focusedWidget.events.notify(ClickActionInvokedEvent());
        }
    }

    override void onMouseDown(in MouseDownEvent event) {
        foreach_reverse (Widget widget; widgetOrdering) {
            if (widget is null || isWidgetFrozen(widget))
                continue;

            if (widget.isEnter) {
                widget.isClick = true;
                widget.isMouseDown = true;

                if (!widget.focusOnMousUp)
                    widget.focus();

                break;
            }
        }
    }

    override void onMouseUp(in MouseUpEvent event) {
        foreach_reverse (Widget widget; widgetOrdering) {
            if (widget is null || isWidgetFrozen(widget))
                continue;

            if (widget.isEnter && widget.focusOnMousUp && widget.isMouseDown)
                widget.focus();

            widget.isClick = false;
            widget.isMouseDown = false;
        }
    }

    override void onMouseWheel(in MouseWheelEvent event) {
        int horizontalDelta = event.dx;
        int verticalDelta = event.dy;

        if (isKeyPressed(KeyCode.Shift)) { // Inverse
            horizontalDelta = event.dy;
            verticalDelta = event.dx;
        }

        Scrollable scrollable = null;
        Widget widget = widgetUnderMouse;

        // Find first scrollable widget
        while (scrollable is null && widget !is null) {
            if (isWidgetFrozen(widget))
                continue;

            scrollable = cast(Scrollable) widget;
            widget = widget.parent;
        }

        if (scrollable !is null)
            scrollable.onMouseWheelHandle(horizontalDelta, verticalDelta);
    }

public:
    Theme theme;
    RenderFactory renderFactory;
    Renderer renderer;

    Cursor.Icon cursor = Cursor.Icon.inherit;

private:
    Application app;
    Array!Rect scissorStack;

    // blur widgets which are in unfocusedWidgets
    void blur() {
        foreach (Widget widget; unfocusedWidgets) {
            widget.p_isFocused = false;
            widget.events.notify(BlurEvent());
        }

        unfocusedWidgets.clear();
    }

package:
    uint lastIndex = 0;
    Widget rootWidget;
    Array!Widget frontWidgets;  // This widgets are drawn last.
    Array!Widget frontWidgetsOrdering;  // This widgets are process firstly.
    Widget focusedWidget = null;
    Array!Widget widgetOrdering;
    Array!Widget unfocusedWidgets;

    SList!Widget freezeSources;
    SList!bool isNestedFreezeStack;

    void moveWidgetToFront(Widget widget) {

        void moveChildrensToFrontOrdering(Widget parentWidget) {
            frontWidgetsOrdering.insert(parentWidget);

            foreach (Widget child; parentWidget.children) {
                moveChildrensToFrontOrdering(child);
            }
        }

        frontWidgets.insert(widget);
        moveChildrensToFrontOrdering(widget);
        widget.parent.children.deleteWidget(widget);
        widget.p_parent = rootWidget;
    }

    @property bool isNestedFreeze() {
        return !isNestedFreezeStack.empty && isNestedFreezeStack.front;
    }

    uint getNextIndex() {
        ++lastIndex  ;
        return lastIndex;
    }

    /**
     * Freez UI except `widget`.
     * If `nestedFreeze` is true then will be frozen all children of widget.
     */
    void freezeUI(Widget widget, in bool nestedFreeze = true) {
        silentPreviousEventsEmitter(widget);
        freezeSources.insert(widget);
        isNestedFreezeStack.insert(nestedFreeze);
        events.join(widget.events);
    }

    /**
     * Unfreeze UI where source of freezing is `widget`.
     */
    void unfreezeUI(Widget widget) {
        if (!freezeSources.empty && freezeSources.front == widget) {
            freezeSources.removeFront();
            isNestedFreezeStack.removeFront();
            unsilentPreviousEventsEmitter(widget);
            events.unjoin(widget.events);
        }
    }

    private void silentPreviousEventsEmitter(Widget widget) {
        if (freezeSources.empty) {
            events.silent(rootWidget.events);
        } else {
            events.silent(freezeSources.front.events);
        }
    }

    private void unsilentPreviousEventsEmitter(Widget widget) {
        if (freezeSources.empty) {
            events.unsilent(rootWidget.events);
        } else {
            events.unsilent(freezeSources.front.events);
        }
    }

    /**
     * Returns true if the `widget` is frozen.
     * If not `isNestedFreeze` then check if `widget` inside freezing source
     * And if `widget` has source parent then this widget is not frozen.
     */
    bool isWidgetFrozen(Widget widget) {
        if (freezeSources.empty || freezeSources.front == widget)
            return false;

        if (!isNestedFreeze) {
            auto freezeSourceParent = widget.resolver.closest(
                (Widget parent) => freezeSources.front == parent
            );
            return freezeSourceParent is null;
        } else {
            return true;
        }
    }

    bool isWidgetFreezingSource(Widget widget) {
        return !freezeSources.empty && freezeSources.front == widget;
    }
}

unittest {
    import test.core : initApp;

    initApp();
    auto manager = new Manager();

    auto scissor1 = Rect(vec2(10, 10), vec2(100, 200));
    auto scissor2 = Rect(vec2(12, 12), vec2(94, 100));
    auto scissor3 = Rect(vec2(50, 150), vec2(94, 100));

    with (manager) {
        pushScissor(scissor1);
        pushScissor(scissor2);
        pushScissor(scissor3);

        const resScissor = applyScissor();

        assert(resScissor.left == scissor3.left);
        assert(resScissor.top == scissor3.top);
        assert(resScissor.width == scissor2.left + scissor3.width - resScissor.left);
        assert(resScissor.height == scissor1.height - resScissor.top - scissor2.top);

        popScissor();
        popScissor();
        popScissor();
    }
}

module ui.manager;

import std.container;
import std.container.array;
import containers.treemap;

import input;
import application;
import math.linalg;
import basic_types;
import accessors;

import derelict.opengl3.gl;
import gapi.camera;

import ui.theme;
import ui.scroll;
import ui.widget;
import ui.cursor;
import ui.render_factory;
import ui.renderer;


class Manager {
    private this() {
        app = Application.getInstance();
        unfocusedWidgets.reserve(20);
    }

    this(in string theme) {
        app = Application.getInstance();

        rootWidget = new Widget(this);
        rootWidget.isOver = true;
        rootWidget.finalFocus = true;
        rootWidget.size.x = app.windowWidth;
        rootWidget.size.y = app.windowHeight;

        theme_ = new Theme(theme);
        renderFactory_ = new RenderFactory(this);
        renderer_ = new Renderer(this);

        unfocusedWidgets.reserve(20);
    }

    void onProgress() {
        rootWidget.onProgress();
        blur();
    }

    void render(Camera camera) {
        cursor = Cursor.Icon.normal;
        rootWidget.size.x = app.windowWidth;
        rootWidget.size.y = app.windowHeight;

        renderer.camera = camera;
        rootWidget.render(camera);
        poll();
        app.cursor = cursor;
    }

    void poll() {
        foreach_reverse (Widget widget; widgetOrdering) {
            if (widget is null)
                continue;

            widget.isEnter = false;

            if (!widget.visible)
                continue;

            widget.onCursor();
            vec2 size = vec2(
                widget.overSize.x > 0 ? widget.overSize.x : widget.size.x,
                widget.overSize.y > 0 ? widget.overSize.y : widget.size.y
            );

            Rect rect = Rect(widget.absolutePosition.x, widget.absolutePosition.y, size.x, size.y);
            widget.isOver = widget.parent.isOver && pointInRect(app.mousePos, rect);
        }

        widgetUnderMouse = null;
        Widget found = null;
        uint counter = 0;

        foreach_reverse (Widget widget; widgetOrdering) {
            if (found !is null && !widget.overlay)
                continue;

            if (widget is null || !widget.isOver || !widget.visible)
                continue;

            if (isWidgetFroze(widget))
                continue;

            if (found !is null) {
                found.isEnter = false;
                found.isClick = false;
            }

            if (widget.pointIsEnter(app.mousePos)) {
                widget.isEnter = true;
                widgetUnderMouse = widget;
                found = widget;
            }

            widget.isClick = (widget.isClick || widget.isFocused) && widget.isEnter &&
                app.mouseButton == MouseButton.mouseLeft;
        }
    }

    void addWidget(Widget widget) {
        rootWidget.addWidget(widget);
    }

    void deleteWidget(Widget widget) {
    }

    void deleteWidget(in int id) {
    }

    Widget findWidget(in string name) {
        return null;
    }

    void pushScissor(in Rect scissor) {
        if (scissorStack.length == 0)
            glEnable(GL_SCISSOR_TEST);

        scissorStack.insertBack(scissor);
        applyScissor();
    }

    void popScissor() {
        scissorStack.removeBack(1);

        if (scissorStack.length == 0) {
            glDisable(GL_SCISSOR_TEST);
        } else {
            applyScissor();
        }
    }

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

    void focusNext() {
        if (focusedWidget !is null)
            focusedWidget.focusNext();
    }

    void focusPrev() {
        if (focusedWidget !is null)
            focusedWidget.focusPrev();
    }

// Events ------------------------------------------------------------------------------------------

    @property
    private Widget eventRootWidget() {
        return freezeSource is null ? rootWidget : freezeSource;
    }

    void onKeyPressed(in KeyCode key) {
        eventRootWidget.onKeyPressed(key);

        if (focusedWidget !is null && isClickKey(key)) {
            focusedWidget.isClick = true;
        }
    }

    void onKeyReleased(in KeyCode key) {
        eventRootWidget.onKeyReleased(key);

        if (focusedWidget !is null && isClickKey(key) && focusedWidget.isClick) {
            focusedWidget.isClick = false;
            focusedWidget.triggerClick();
        }
    }

    void onTextEntered(in utfchar key) {
        eventRootWidget.onTextEntered(key);
    }

    void onMouseDown(in uint x, in uint y, in MouseButton button) {
        eventRootWidget.onMouseDown(x, y, button);

        foreach_reverse (Widget widget; widgetOrdering) {
            if (widget is null || isWidgetFroze(widget))
                continue;

            if (widget.isEnter) {
                widget.isClick = true;
                break;
            }
        }
    }

    void onMouseUp(in uint x, in uint y, in MouseButton button) {
        foreach_reverse (Widget widget; widgetOrdering) {
            if (widget is null || isWidgetFroze(widget))
                continue;

            if (widget.isEnter) {
                widget.focus();
                break;
            }
        }

        eventRootWidget.onMouseUp(x, y, button);
    }

    void onDblClick(in uint x, in uint y, in MouseButton button) {
        eventRootWidget.onDblClick(x, y, button);
    }

    void onMouseMove(in uint x, in uint y) {
        eventRootWidget.onMouseMove(x, y);
    }

    void onMouseWheel(in int dx, in int dy) {
        eventRootWidget.onMouseWheel(dx, dy);

        Scrollable scrollable = null;
        Widget widget = widgetUnderMouse;

        // Find first scrollable widget
        while (scrollable is null && widget !is null) {
            if (isWidgetFroze(widget))
                continue;

            scrollable = cast(Scrollable) widget;
            widget = widget.parent;
        }

        if (scrollable !is null)
            scrollable.onMouseWheelHandle(dx, dy);
    }

// Properties --------------------------------------------------------------------------------------

private:
    @Read @Write("private") {
        Theme theme_;
        RenderFactory renderFactory_;
        Renderer renderer_;
        Widget widgetUnderMouse_ = null;
    }

    @Read @Write
    Cursor.Icon cursor_ = Cursor.Icon.normal;

    mixin(GenerateFieldAccessors);

private:
    Application app;
    Array!Rect scissorStack;

    // blur widgets which are in unfocusedWidgets
    void blur() {
        foreach (Widget widget; unfocusedWidgets) {
            widget.p_isFocused = false;

            if (widget.onBlurListener !is null)
                widget.onBlurListener(widget);
        }

        unfocusedWidgets.clear();
    }

package:
    uint lastIndex = 0;
    Widget rootWidget;
    Widget focusedWidget = null;
    Array!Widget widgetOrdering;
    Array!Widget unfocusedWidgets;

    Widget freezeSource = null;
    private bool isNestedFreeze = false;

    uint getNextIndex() {
        ++lastIndex  ;
        return lastIndex;
    }

    // TODO: write description
    void freezeUI(Widget widget, bool nestedFreeze = true) {
        this.freezeSource = widget;
        this.isNestedFreeze = nestedFreeze;
    }

    void unfreezeUI(Widget widget) {
        if (this.freezeSource == widget)
            this.freezeSource = null;
    }

    // TODO: write description
    bool isWidgetFroze(Widget widget) const {
        if (freezeSource is null || freezeSource == widget)
            return false;

        if (!isNestedFreeze) {
            auto freezeSourceParent = widget.closest((Widget parent) => freezeSource == parent);
            return freezeSourceParent is null;
        } else {
            return true;
        }
    }

    bool isWidgetFrozeSource(Widget widget) const {
        return freezeSource == widget;
    }
}

unittest {
    import test.core;

    initApp();
    Manager manager = new Manager();

    auto scissor1 = Rect(vec2(10, 10), vec2(100, 200));
    auto scissor2 = Rect(vec2(12, 12), vec2(94, 100));
    auto scissor3 = Rect(vec2(50, 150), vec2(94, 100));

    with (manager) {
        pushScissor(scissor1);
        pushScissor(scissor2);
        pushScissor(scissor3);

        auto resScissor = applyScissor();

        assert(resScissor.left == scissor3.left);
        assert(resScissor.top == scissor3.top);
        assert(resScissor.width == scissor2.left + scissor3.width - resScissor.left);
        assert(resScissor.height == scissor1.height - resScissor.top - scissor2.top);

        popScissor();
        popScissor();
        popScissor();
    }
}

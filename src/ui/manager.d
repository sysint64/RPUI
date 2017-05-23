module ui.manager;

import std.container;
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
    }

    this(in string theme) {
        app = Application.getInstance();

        rootWidget = new Widget(this);
        rootWidget.isOver = true;
        rootWidget.size.x = app.windowWidth;
        rootWidget.size.y = app.windowHeight;

        theme_ = new Theme(theme);
        renderFactory_ = new RenderFactory(this);
        renderer_ = new Renderer(this);
    }

    void onProgress() {
        rootWidget.onProgress();
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

            if (found !is null) {
                found.isEnter = false;
                found.isClick = false;
            }

            if (widget.pointIsEnter(app.mousePos)) {
                widget.isEnter = true;
                widgetUnderMouse = widget;
                found = widget;
            }

            widget.isClick = (widget.isClick || widget.focused) && widget.isEnter &&
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
        enum {left = 0, top = 1, right = 2, bottom = 3}
        vec4 currentScissor = scissorStack.back.absolute;

        if (scissorStack.length >= 2) {
            foreach (Rect scissor; scissorStack) {
                if (currentScissor.vector[left] < scissor.absolute.vector[left])
                    currentScissor.vector[left] = scissor.absolute.vector[left];

                if (currentScissor.vector[top] < scissor.absolute.vector[top])
                    currentScissor.vector[top] = scissor.absolute.vector[top];

                if (currentScissor.vector[right] > scissor.absolute.vector[right])
                    currentScissor.vector[right] = scissor.absolute.vector[right];

                if (currentScissor.vector[bottom] > scissor.absolute.vector[bottom])
                    currentScissor.vector[bottom] = scissor.absolute.vector[bottom];
            }
        }

        auto resultScissorRect = Rect(
            currentScissor.vector[left],
            currentScissor.vector[top],
            currentScissor.vector[right] - currentScissor.vector[left],
            currentScissor.vector[bottom] - currentScissor.vector[top]
        );

        auto screenScissor = IntRect(resultScissorRect);
        screenScissor.top = app.windowHeight - screenScissor.top - screenScissor.height;
        glScissor(screenScissor.left, screenScissor.top, screenScissor.width, screenScissor.height);

        return resultScissorRect;
    }

// Events ------------------------------------------------------------------------------------------

    void onKeyPressed(in KeyCode key) {
        rootWidget.onKeyPressed(key);
    }

    void onKeyReleased(in KeyCode key) {
        rootWidget.onKeyReleased(key);
    }

    void onTextEntered(in utfchar key) {
        rootWidget.onTextEntered(key);
    }

    void onMouseDown(in uint x, in uint y, in MouseButton button) {
        foreach_reverse (Widget widget; widgetOrdering) {
            if (widget is null)
                continue;

            if (widget.isEnter) {
                widget.isClick = true;
                break;
            }
        }

        rootWidget.onMouseDown(x, y, button);
    }

    void onMouseUp(in uint x, in uint y, in MouseButton button) {
        rootWidget.onMouseUp(x, y, button);
    }

    void onDblClick(in uint x, in uint y, in MouseButton button) {
        rootWidget.onDblClick(x, y, button);
    }

    void onMouseMove(in uint x, in uint y) {
        rootWidget.onMouseMove(x, y);
    }

    void onMouseWheel(in int dx, in int dy) {
        rootWidget.onMouseWheel(dx, dy);

        Scrollable scrollable = null;
        Widget widget = widgetUnderMouse;

        // Find first scrollable widget
        while (scrollable is null && widget !is null) {
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
    Widget focusedWidget = null;

package:
    uint lastIndex = 0;
    Widget rootWidget;
    Array!Widget widgetOrdering;

    uint getNextIndex() {
        ++lastIndex  ;
        return lastIndex;
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
        assert(-resScissor.height == scissor1.height - resScissor.top - scissor2.top);

        popScissor();
        popScissor();
        popScissor();
    }
}

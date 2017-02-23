module ui.manager;

import std.container;
import containers.treemap;

import input;
import application;
import math.linalg;
import basic_types;

import derelict.opengl3.gl;
import gapi.camera;

import ui.theme;
import ui.widget;
import ui.cursor;
import ui.render_factory;
import ui.renderer;


class Manager {
    this(in string theme) {
        app = Application.getInstance();

        root = new Widget(this);
        root.isOver = true;
        root.size.x = app.windowWidth;
        root.size.y = app.windowHeight;

        p_theme = new Theme(theme);
        p_renderFactory = new RenderFactory(this);
        p_renderer = new Renderer(this);
    }

    void render(Camera camera) {
        root.size.x = app.windowWidth;
        root.size.y = app.windowHeight;

        p_renderer.camera = camera;
        root.render(camera);
        poll();
    }

    void poll() {
        foreach_reverse (Widget widget; widgetOrdering) {
            if (widget is null)
                continue;

            widget.isEnter = false;

            if (!widget.visible)
                continue;

            vec2 size = vec2(widget.overSize.x > 0 ? widget.overSize.x : widget.size.x,
                             widget.overSize.y > 0 ? widget.overSize.y : widget.size.y);
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
        root.addWidget(widget);
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

    void applyScissor() {
        Rect currentScissor = scissorStack.back;

        if (scissorStack.length >= 2) {
            foreach (Rect scissor; scissorStack) {
                if (currentScissor.left < scissor.left)
                    currentScissor.left = scissor.left;

                if (currentScissor.top < scissor.top)
                    currentScissor.top = scissor.top;

                if (currentScissor.width > scissor.width)
                    currentScissor.width = scissor.width;

                if (currentScissor.height > scissor.height)
                    currentScissor.height = scissor.height;
            }
        }

        IntRect intScissor = IntRect(currentScissor);
        glScissor(intScissor.left,
                  app.windowHeight - intScissor.top - intScissor.height,
                  intScissor.width,
                  intScissor.height);
    }

    // Events --------------------------------------------------------------------------------------

    void onKeyPressed(in KeyCode key) {
        root.onKeyPressed(key);
    }

    void onKeyReleased(in KeyCode key) {
        root.onKeyReleased(key);
    }

    void onTextEntered(in utfchar key) {
        root.onTextEntered(key);
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

        root.onMouseDown(x, y, button);
    }

    void onMouseUp(in uint x, in uint y, in MouseButton button) {
        root.onMouseDown(x, y, button);
    }

    void onDblClick(in uint x, in uint y, in MouseButton button) {
        root.onDblClick(x, y, button);
    }

    void onMouseMove(in uint x, in uint y) {
        root.onMouseMove(x, y);
    }

    void onMouseWheel(in int dx, in int dy) {
        root.onMouseWheel(dx, dy);
    }

    // Properties ----------------------------------------------------------------------------------

    @property Theme theme() { return p_theme; }
    @property Cursor.Icon cursor() { return p_cursor; }
    @property RenderFactory renderFactory() { return p_renderFactory; }
    @property Renderer renderer() { return p_renderer; }

private:
    Application app;
    Array!Rect scissorStack;

    Theme p_theme;
    Cursor.Icon p_cursor = Cursor.Icon.normal;
    RenderFactory p_renderFactory;
    Renderer p_renderer;

    Widget root;
    Widget focusedWidget = null;
    Widget widgetUnderMouse = null;

package:
    uint lastIndex = 0;
    Array!Widget widgetOrdering;

    uint getNextIndex() {
        ++lastIndex  ;
        return lastIndex;
    }
}

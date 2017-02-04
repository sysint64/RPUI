module ui.manager;

import application;
import std.container;
import math.linalg;

import gapi.camera;

import ui.theme;
import ui.widget;
import ui.cursor;
import ui.render_factory;
import ui.renderer;


class Manager {
    this(in string theme) {
        root = new Widget(this);
        app = Application.getInstance();

        p_theme = new Theme(theme);
        p_renderFactory = new RenderFactory(this);
        p_renderer = new Renderer(this);
    }

    void render(Camera camera) {
        p_renderer.camera = camera;
        root.render(camera);
    }

    void poll() {
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

    void pushScissor(in vec4i scissor) {
    }

    void popScissor() {
    }

    void applyScissor() {
    }

    @property Theme theme() { return p_theme; }
    @property Cursor.Icon cursor() { return p_cursor; }
    @property RenderFactory renderFactory() { return p_renderFactory; }
    @property Renderer renderer() { return p_renderer; }

private:
    Application app;
    Array!vec4i scissorStack;

    Theme p_theme;
    Cursor.Icon p_cursor = Cursor.Icon.normal;
    RenderFactory p_renderFactory;
    Renderer p_renderer;

    Widget root;
    Widget focusedWidget = null;
    Widget underMouseWidget = null;

package:
    uint lastIndex = 0;

    uint getNextIndex() {
        ++lastIndex  ;
        return lastIndex;
    }
}

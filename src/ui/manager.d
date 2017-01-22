module ui.manager;

import application;
import std.container;
import math.linalg;

import ui.theme;
import ui.widget;
import ui.cursor;


class Manager {
    void render() {
    }

    void poll() {
    }

    void addWidget(Widget widget) {
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

private:
    Application app;
    Array!vec4i scissorStack;

    Theme p_theme;
    Cursor.Icon p_cursor = Cursor.Icon.normal;

    Widget root;
    Widget focusedWidget = null;
    Widget underMouseWidget = null;
}

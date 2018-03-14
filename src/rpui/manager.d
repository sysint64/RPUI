/**
 * Manager of all UI elements.
 *
 * Copyright: © 2017 RedGoosePaws
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 * Authors: Andrey Kabylin
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

import derelict.opengl3.gl;
import gapi.camera;

import rpui.theme;
import rpui.scroll;
import rpui.widget;
import rpui.cursor;
import rpui.render_factory;
import rpui.renderer;

/**
 * Manager of all widgets.
 */
class Manager {
    StringsRes stringsRes;  /// String resources for internationalization.
    ImagesRes imagesRes;  /// Image resources.
    IconsRes iconsRes;  /// Icons resources.
    ShadersRes shadersRes;

    private Widget p_widgetUnderMouse = null;
    @property Widget widgetUnderMouse() { return p_widgetUnderMouse; }

    private this() {
        app = Application.getInstance();
        unfocusedWidgets.reserve(20);
    }

    /// Creating manager with particular theme.
    this(in string themeName) {
        app = Application.getInstance();

        with (rootWidget = new Widget(this)) {
            isOver = true;
            finalFocus = true;
            size.x = this.app.windowWidth;
            size.y = this.app.windowHeight;
        }


        this.imagesRes = new ImagesRes(themeName);
        this.iconsRes = new IconsRes(this.imagesRes);
        this.shadersRes = new ShadersRes();

        this.theme = new Theme(themeName);
        this.renderFactory = new RenderFactory(this);
                            import std.stdio;
            writeln("Hello world!");

        this.renderer = new Renderer(this);

        unfocusedWidgets.reserve(20);
    }

    /// Invokes all `onProgress` of all widgets and `poll` widgets.
    void onProgress() {
        cursor = Cursor.Icon.normal;
        rootWidget.onProgress();
        poll();
        blur();
        app.cursor = cursor;
    }

    /// Renders all widgets inside `camera` view.
    void render(Camera camera) {
        rootWidget.size.x = app.windowWidth;
        rootWidget.size.y = app.windowHeight;

        renderer.camera = camera;
        rootWidget.render(camera);
    }

    /**
     * Determines widgets states - check when widget `isEnter` (i.e. mouse inside widget area);
     * `isClick` (when user clicked to widget) and when widget is over i.e. mouse inside widget area
     * but widget can be overlapped by another widget.
     */
    private void poll() {
        foreach_reverse (Widget widget; widgetOrdering) {
            if (widget is null)
                continue;

            widget.isEnter = false;

            if (!widget.visible)
                continue;

            if (!isWidgetFrozen(widget))
                widget.onCursor();

            const size = vec2(
                widget.overSize.x > 0 ? widget.overSize.x : widget.size.x,
                widget.overSize.y > 0 ? widget.overSize.y : widget.size.y
            );

            Rect rect = Rect(widget.absolutePosition, size);
            widget.isOver = widget.parent.isOver && pointInRect(app.mousePos, rect);
        }

        p_widgetUnderMouse = null;
        Widget found = null;

        foreach_reverse (Widget widget; widgetOrdering) {
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
            }

            widget.isClick = (widget.isClick || widget.isFocused) && widget.isEnter &&
                app.mouseButton == MouseButton.mouseLeft;
        }
    }

    /// Add `widget` to root children.
    void addWidget(Widget widget) {
        rootWidget.addWidget(widget);
    }

    /// Delete `widget` from root children.
    void deleteWidget(Widget widget) {
        rootWidget.deleteWidget(widget);
    }

    /// Delete widget by `id` from root children.
    void deleteWidget(in size_t id) {
        rootWidget.deleteWidget(id);
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
            focusedWidget.focusNext();
    }

    /// Focusing previous widget before the current focused widget.
    void focusPrev() {
        if (focusedWidget !is null)
            focusedWidget.focusPrev();
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
            focusedWidget.onClickActionInvoked();
        }
    }

    void onTextEntered(in utfchar key) {
        eventRootWidget.onTextEntered(key);
    }

    void onMouseDown(in uint x, in uint y, in MouseButton button) {
        eventRootWidget.onMouseDown(x, y, button);

        foreach_reverse (Widget widget; widgetOrdering) {
            if (widget is null || isWidgetFrozen(widget))
                continue;

            if (widget.isEnter) {
                widget.isClick = true;
                break;
            }
        }
    }

    void onMouseUp(in uint x, in uint y, in MouseButton button) {
        foreach_reverse (Widget widget; widgetOrdering) {
            if (widget is null || isWidgetFrozen(widget))
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
        int horizontalDelta = dx;
        int verticalDelta = dy;

        if (isKeyPressed(KeyCode.Shift)) { // Inverse
            horizontalDelta = dy;
            verticalDelta = dx;
        }

        eventRootWidget.onMouseWheel(horizontalDelta, verticalDelta);

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

package:
    Theme theme;
    RenderFactory renderFactory;
    Renderer renderer;

    Cursor.Icon cursor = Cursor.Icon.normal;

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

    SList!Widget freezeSources;
    SList!bool isNestedFreezeStack;

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
    void freezeUI(Widget widget, bool nestedFreeze = true) {
        this.freezeSources.insert(widget);
        this.isNestedFreezeStack.insert(nestedFreeze);
    }

    /**
     * Unfreeze UI where source of freezing is `widget`.
     */
    void unfreezeUI(Widget widget) {
        if (this.freezeSources.front == widget) {
            this.freezeSources.removeFront();
            this.isNestedFreezeStack.removeFront();
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
            auto freezeSourceParent = widget.closest(
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

module rpui.view;

import std.algorithm;
import std.path;
import std.file;
import std.container.array;
import std.container.slist;

import gapi.vec;
import gapi.opengl;
import gapi.shader;
import gapi.camera;

import rpui.shortcuts : Shortcuts;
import rpui.platform;
import rpui.input;
import rpui.cursor;
import rpui.widget;
import rpui.events_observer;
import rpui.events;
import rpui.widget_events;
import rpui.primitives;
import rpui.math;
import rpui.theme;
import rpui.render.components : CameraView;
import rpui.resources.strings;
import rpui.resources.images;
import rpui.resources.icons;

struct ViewResources {
    StringsRes strings;
    ImagesRes images;
    IconsRes icons;
}

ViewResources createViewResources(in string theme) {
    auto images = new ImagesRes(theme);
    auto icons = new IconsRes(images);

    icons.addIcons("icons", "icons.rdl");

    return ViewResources(
        new StringsRes(),
        images,
        icons
    );
}

final class View : EventsListenerEmpty {
    Theme theme;
    EventsObserver events;
    package Array!Widget onProgressQueries;

    @property Shortcuts shortcuts() { return shortcuts_; }
    private Shortcuts shortcuts_;

    private Widget p_widgetUnderMouse = null;
    @property Widget widgetUnderMouse() { return p_widgetUnderMouse; }

    private Subscriber rootWidgetSubscriber;

    private uint lastIndex = 0;
    package Widget rootWidget;
    package Array!Widget frontWidgets;  // This widgets are drawn last.
    package Array!Widget frontWidgetsOrdering;  // This widgets are process firstly.
    package Array!Widget frontWidgetsRenderQueries;
    package Widget focusedWidget = null;
    package Array!Widget widgetOrdering;
    package Array!Widget unfocusedWidgets;

    package SList!Widget freezeSources;
    package SList!bool isNestedFreezeStack;

    public CursorIcon cursor = CursorIcon.inherit;
    package vec2i mousePos = vec2i(-1, -1);
    package vec2i mouseClickPos = vec2i(-1, -1);
    private Array!Rect scissorStack;
    private uint viewportHeight;

    public @property inout(CameraView) cameraView() inout { return cameraView_; }
    package CameraView cameraView_;

    package ViewResources resources;
    private CursorManager cursorManager;

    private void* window;

    private CameraMatrices screenCameraMatrices;
    private OthroCameraTransform screenCameraTransform = {
        viewportSize: vec2(1024, 768),
        position: vec2(0, 0),
        zoom: 1f
    };

    private this() {
        events = new EventsObserver();
    }

    this(void* window, in string themeName, CursorManager cursorManager, ViewResources resources) {
        with (rootWidget = new Widget(this)) {
            isOver = true;
            finalFocus = true;
        }

        events = new EventsObserver();
        events.join(rootWidget.events);

        theme = createThemeByName(themeName);
        this.resources = resources;
        this.cursorManager = cursorManager;
        this.window = window;
        this.shortcuts_ = Shortcuts.createFromFile("general.rdl");
    }

    this(void* window, in string themeName) {
        with (rootWidget = new Widget(this)) {
            isOver = true;
            finalFocus = true;
        }

        events = new EventsObserver();
        events.join(rootWidget.events);

        theme = createThemeByName(themeName);
        this.resources = createViewResources(themeName);
        this.window = window;
    }

    /// Invokes all `onProgress` of all widgets and `poll` widgets.
    void onProgress(in ProgressEvent event) {
        screenCameraMatrices = createOrthoCameraMatrices(screenCameraTransform);
        cursor = CursorIcon.inherit;

        onProgressQueries.clear();
        rootWidget.collectOnProgressQueries();

        foreach (Widget widget; frontWidgets) {
            if (!widget.isVisible && !widget.processPorgress())
                continue;

            widget.collectOnProgressQueries();
        }

        blur();

        foreach (Widget widget; onProgressQueries) {
            widget.onProgress(event);
        }

        foreach_reverse (Widget widget; onProgressQueries) {
            widget.onProgress(event);
        }

        poll();

        foreach (Widget widget; frontWidgets) {
            if (!widget.isVisible && !widget.processPorgress())
                continue;

            if (widget.isOver)
                cursor = CursorIcon.inherit;
        }

        rootWidget.updateAll();
        cursorManager.setIcon(cursor);
    }

    /// Renders all widgets inside `camera` view.
    void onRender() {
        cameraView_.mvpMatrix = screenCameraMatrices.mvpMatrix;
        cameraView_.viewportWidth = screenCameraTransform.viewportSize.x;
        cameraView_.viewportHeight = screenCameraTransform.viewportSize.y;

        rootWidget.size.x = screenCameraTransform.viewportSize.x;
        rootWidget.size.y = screenCameraTransform.viewportSize.y;

        frontWidgetsRenderQueries.clear();
        rootWidget.onRender();

        foreach (Widget widget; frontWidgetsRenderQueries) {
            if (widget.isVisible) {
                widget.onRender();
            }
        }

        foreach (Widget widget; frontWidgets) {
            if (widget.isVisible) {
                widget.onRender();
            }
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

            if (!widget.isVisible || !widget.isEnabled) {
                widget.isOver = false;
                widget.isEnter = false;
                widget.isClick = false;
                continue;
            }

            if (!isWidgetFrozen(widget)) {
                widget.onCursor();
            }

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

            widget.isOver = widget.parent.isOver && pointInRect(mousePos, rect);
        }

        p_widgetUnderMouse = null;
        Widget found = null;

        foreach_reverse (Widget widget; widgetsOrderingChain) {
            if (found !is null && !widget.overlay)
                continue;

            if (widget is null || !widget.isOver || !widget.isVisible)
                continue;

            if (isWidgetFrozen(widget))
                continue;

            if (found !is null) {
                found.isEnter = false;
                found.isClick = false;
            }

            if (widget.pointIsEnter(mousePos)) {
                widget.isEnter = true;
                p_widgetUnderMouse = widget;
                found = widget;

                if (cursor == CursorIcon.inherit) {
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

        if (currentScissor.right < currentScissor.left) {
            currentScissor.right = currentScissor.left;
        }

        if (currentScissor.bottom < currentScissor.top) {
            currentScissor.bottom = currentScissor.top;
        }

        auto screenScissor = IntRect(currentScissor);
        screenScissor.top = viewportHeight - screenScissor.top - screenScissor.height;
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
        shortcuts_.onKeyReleased(event.key);

        if (focusedWidget !is null && isClickKey(event.key)) {
            focusedWidget.isClick = false;
            focusedWidget.onClickActionInvoked();
            focusedWidget.events.notify(ClickEvent());
            focusedWidget.events.notify(ClickActionInvokedEvent());
        }
    }

    override void onMouseDown(in MouseDownEvent event) {
        mouseClickPos.x = event.x;
        mouseClickPos.y = event.y;

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

    override void onMouseMove(in MouseMoveEvent event) {
        mousePos.x = event.x;
        mousePos.y = event.y;
    }

    override void onWindowResize(in WindowResizeEvent event) {
        viewportHeight = event.height;
        screenCameraTransform.viewportSize.x = event.width;
        screenCameraTransform.viewportSize.y = event.height;

        onProgress(ProgressEvent(0));
        onRender();
    }

    private void blur() {
        foreach (Widget widget; unfocusedWidgets) {
            widget.p_isFocused = false;
            widget.events.notify(BlurEvent());
        }

        unfocusedWidgets.clear();
    }

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

    void queryRenderWidgetInFront(Widget widget) {
        frontWidgetsRenderQueries.insert(widget);
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
                (Widget parent) => parent.view.freezeSources.front == parent
            );
            return freezeSourceParent is null;
        } else {
            return true;
        }
    }

    bool isWidgetFreezingSource(Widget widget) {
        return !freezeSources.empty && freezeSources.front == widget;
    }

    void showCursor() {
        platformShowSystemCursor();
    }

    void hideCursor() {
        platformHideSystemCursor();
    }

    void setMousePositon(in int x, in int y) {
        platformSetMousePosition(window, x, y);
    }
}

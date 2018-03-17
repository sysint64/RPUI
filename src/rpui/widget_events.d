module rpui.widget_events;

import std.container.array;

import input;
import basic_types;

import rpui.widget;
import rpui.events;

class WidgetEvents : Events {
    private Widget owner;

    this (Widget widget) {
        this.owner = widget;
    }

    void onCreate() {

    }

    void onKeyPressed(in KeyCode key) {
        foreach (Widget widget; owner.children) {
            if (widget.isFrozen())
                continue;

            widget.onKeyPressed(key);
            widget.eventsSubject.notify!("KeyPressed")(key);
        }
    }

    void onKeyReleased(in KeyCode key) {
        foreach (Widget widget; owner.children) {
            if (widget.isFrozen())
                continue;

            widget.onKeyReleased(key);
            widget.eventsSubject.notify!("KeyReleased")(key);
        }
    }

    void onTextEntered(in utfchar key) {
        foreach (Widget widget; owner.children) {
            if (widget.isFrozen())
                continue;

            widget.onTextEntered(key);
            widget.eventsSubject.notify!("TextEntered")(key);
        }
    }

    void onMouseDown(in uint x, in uint y, in MouseButton button) {
        foreach (Widget widget; owner.children) {
            if (widget.isFrozen())
                continue;

            widget.onMouseDown(x, y, button);

            if (widget.isEnter)
                widget.eventsSubject.notify!("MouseDown")(x, y, button);
        }
    }

    void onMouseUp(in uint x, in uint y, in MouseButton button) {
        foreach (Widget widget; owner.children) {
            if (widget.isFrozen())
                continue;

            widget.onMouseUp(x, y, button);

            if (widget.isEnter) {
                widget.eventsSubject.notify!("MouseUp")(x, y, button);
                widget.triggerClick();
            }
        }
    }

    void onDblClick(in uint x, in uint y, in MouseButton button) {
        foreach (Widget widget; owner.children) {
            if (widget.isFrozen())
                continue;

            widget.onDblClick(x, y, button);

            if (widget.isEnter)
                widget.triggerDblClick();
        }
    }

    void onMouseMove(in uint x, in uint y) {
        foreach (Widget widget; owner.children) {
            if (widget.isFrozen())
                continue;

            widget.onMouseMove(x, y);

            if (widget.isEnter)
                widget.eventsSubject.notify!("MouseMove")(x, y);
        }
    }

    void onMouseWheel(in int dx, in int dy) {
        foreach (Widget widget; owner.children) {
            if (widget.isFrozen())
                continue;

            widget.onMouseWheel(dx, dy);

            if (widget.isEnter)
                widget.eventsSubject.notify!("MouseWheel")(dx, dy);
        }
    }

    /// Override this method if need change behaviour when system cursor have to be changed.
    void onCursor() {
    }

    /// Invoke when widget resize.
    void onResize() {
        foreach (Widget widget; owner.children) {
            widget.onResize();
            widget.eventsSubject.notify!("Resize")();
        }
    }

    void onWindowResize(in uint width, in uint height) {
        foreach (Widget widget; owner.children) {
            widget.onResize();
            widget.eventsSubject.notify!("WindowResize")(width, height);
        }
    }
}

alias OnClickListener = void delegate(Widget);
alias OnDblClickListener = void delegate(Widget);
alias OnFocusListener = void delegate(Widget);
alias OnBlurListener = void delegate(Widget);
alias OnKeyPressedListener = void delegate(Widget, in KeyCode key);
alias OnKeyReleasedListener = void delegate(Widget, in KeyCode key);
alias OnTextEnteredListener = void delegate(Widget, in utfchar key);
alias OnMouseMoveListener = void delegate(Widget, in uint x, in uint y);
alias OnMouseWheelListener = void delegate(Widget, in int dx, in int dy);
alias OnMouseEnterListener = void delegate(Widget, in uint x, in uint y);
alias OnMouseLeaveListener = void delegate(Widget, in uint x, in uint y);
alias OnMouseDownListener = void delegate(Widget, in uint x, in uint y, in MouseButton button);
alias OnMouseUpListener = void delegate(Widget, in uint x, in uint y, in MouseButton button);
alias OnWindowResizeListener = void delegate(Widget, in uint width, in uint height);
alias OnResizeListener = void delegate(Widget);

final class WidgetEventsSubject {
    private struct Subscribers {
        Array!OnClickListener onClick;
        Array!OnDblClickListener onDblClick;
        Array!OnFocusListener onFocus;
        Array!OnBlurListener onBlur;
        Array!OnKeyPressedListener onKeyPressed;
        Array!OnKeyReleasedListener onKeyReleased;
        Array!OnTextEnteredListener onTextEntered;
        Array!OnMouseMoveListener onMouseMove;
        Array!OnMouseWheelListener onMouseWheel;
        Array!OnMouseEnterListener onMouseEnter;
        Array!OnMouseLeaveListener onMouseLeave;
        Array!OnMouseDownListener onMouseDown;
        Array!OnMouseUpListener onMouseUp;
        Array!OnWindowResizeListener onWindowResize;
        Array!OnResizeListener onResize;
    }

    private Subscribers subscribers;
    private Widget widget;

    void notify(string event, T...)(T args) {
        const eventSubscribers = mixin("this.subscribers.on" ~ event);

        foreach (subscriber; eventSubscribers) {
            subscriber(widget, args);
        }
    }
}

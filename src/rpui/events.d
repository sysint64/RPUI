module rpui.events;

import input;
import basic_types;

struct KeyPressedEvent {
    KeyCode key;
}

struct KeyReleasedEvent {
    KeyCode key;
}

struct TextEnteredEvent {
    utfchar key;
}

struct MouseDownEvent {
    uint x;
    uint y;
    MouseButton button;
}

struct MouseUpEvent {
    uint x;
    uint y;
    MouseButton button;
}

struct DblClickEvent {
    uint x;
    uint y;
    MouseButton button;
}

struct MouseMoveEvent {
    uint x;
    uint y;
}

struct MouseWheelEvent {
    int dx;
    int dy;
}

struct WindowResizeEvent {
    uint width;
    uint height;
}

interface EventsListener {
    void onKeyPressed(in KeyPressedEvent event);
    void onKeyReleased(in KeyReleasedEvent event);
    void onTextEntered(in TextEnteredEvent event);
    void onMouseDown(in MouseDownEvent event);
    void onMouseUp(in MouseUpEvent event);
    void onDblClick(in DblClickEvent event);
    void onMouseMove(in MouseMoveEvent event);
    void onMouseWheel(in MouseWheelEvent event);
    void onWindowResize(in WindowResizeEvent event);
}

abstract class EventsListenerEmpty : EventsListener {
    void onKeyPressed(in KeyPressedEvent event) {}
    void onKeyReleased(in KeyReleasedEvent event) {}
    void onTextEntered(in TextEnteredEvent event) {}
    void onMouseDown(in MouseDownEvent event) {}
    void onMouseUp(in MouseUpEvent event) {}
    void onDblClick(in DblClickEvent event) {}
    void onMouseMove(in MouseMoveEvent event) {}
    void onMouseWheel(in MouseWheelEvent event) {}
    void onWindowResize(in WindowResizeEvent event) {}
}

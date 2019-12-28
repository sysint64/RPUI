module rpui.events;

import rpui.math;
import rpui.input;
import rpui.primitives;

struct ProgressEvent {
    float deltaTime;
}

struct CreateEvent {
}

struct KeyPressedEvent {
    KeyCode key;
}

struct KeyReleasedEvent {
    KeyCode key;
}

struct TextEnteredEvent {
    utf32string key;
}

struct ChangeEvent {
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

struct TripleClickEvent {
    uint x;
    uint y;
    MouseButton button;
}

struct MouseMoveEvent {
    int x;
    int y;
    MouseButton button;
}

struct MouseWheelEvent {
    int dx;
    int dy;
}

struct WindowResizeEvent {
    uint width;
    uint height;
    uint originalWidth;
    uint originalHeight;
}

struct WindowExposedEvent {
}

struct CopyCommand {
}

struct PasteCommand {
}

struct CutCommand {
}

struct UnselectCommand {
}

struct SelectAllCommand {
}

const windowEvents = [
    typeid(KeyPressedEvent),
    typeid(KeyReleasedEvent),
    typeid(TextEnteredEvent),
    typeid(MouseDownEvent),
    typeid(MouseUpEvent),
    typeid(DblClickEvent),
    typeid(TripleClickEvent),
    typeid(MouseMoveEvent),
    typeid(MouseWheelEvent),
    typeid(WindowResizeEvent),
    typeid(WindowExposedEvent),
];

const commands = [
    typeid(CopyCommand),
    typeid(CutCommand),
    typeid(PasteCommand),
    typeid(UnselectCommand),
    typeid(SelectAllCommand),
];

interface EventsListener {
    void onKeyPressed(in KeyPressedEvent event);
    void onKeyReleased(in KeyReleasedEvent event);
    void onTextEntered(in TextEnteredEvent event);
    void onMouseDown(in MouseDownEvent event);
    void onMouseUp(in MouseUpEvent event);
    void onDblClick(in DblClickEvent event);
    void onTripleClick(in TripleClickEvent event);
    void onMouseMove(in MouseMoveEvent event);
    void onMouseWheel(in MouseWheelEvent event);
    void onWindowResize(in WindowResizeEvent event);
    void onWindowExposed(in WindowExposedEvent event);
}

abstract class EventsListenerEmpty : EventsListener {
    void onKeyPressed(in KeyPressedEvent event) {}
    void onKeyReleased(in KeyReleasedEvent event) {}
    void onTextEntered(in TextEnteredEvent event) {}
    void onMouseDown(in MouseDownEvent event) {}
    void onMouseUp(in MouseUpEvent event) {}
    void onDblClick(in DblClickEvent event) {}
    void onTripleClick(in TripleClickEvent event) {}
    void onMouseMove(in MouseMoveEvent event) {}
    void onMouseWheel(in MouseWheelEvent event) {}
    void onWindowResize(in WindowResizeEvent event) {}
    void onWindowExposed(in WindowExposedEvent event) {}
}

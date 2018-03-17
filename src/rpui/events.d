module rpui.events;

import input;
import basic_types;

interface Events {
    void onKeyPressed(in KeyCode key);

    void onKeyReleased(in KeyCode key);

    void onTextEntered(in utfchar key);

    void onMouseDown(in uint x, in uint y, in MouseButton button);

    void onMouseUp(in uint x, in uint y, in MouseButton button);

    void onDblClick(in uint x, in uint y, in MouseButton button);

    void onMouseMove(in uint x, in uint y);

    void onMouseWheel(in int dx, in int dy);

    void onWindowResize(in uint width, in uint height);
}

final class EventsObserver {
    void notify(string event, T...)(T args) {
        auto listener = mixin("this.on" ~ event ~ "Listener");

        if (listener !is null) {
            listener(this, args);
        }
    }
}

module rpui.platform;

import rpui.events_observer;
import rpui.primitives;

struct Window {
    void* handle;
    void* gapiContext;
}

extern(C) void platformShowSystemCursor();

extern(C) void platformHideSystemCursor();

extern(C) void platformSetMousePosition(void* window, in int x, in int y);

extern(C) float platformGetTicks();

extern(C) bool platformEventLoop(void* window, EventsObserver events);

extern(C) void platformSwapWindow(void* window);

extern(C) void platformGapiDeleteContext(void* context);

extern(C) void platformDestroyWindow(void* window);

extern(C) void platformShutdown();

extern(C) void platformInit();

extern(C) Window platformCreateWindow(in string title, uint width, uint height);

extern(C) void platformSetClipboardTextUtf8(in string text);

extern(C) void platformSetClipboardTextUtf32(in dstring text);

extern(C) string platformGetClipboardTextUtf8();

extern(C) dstring platformGetClipboardTextUtf32();

extern(C) bool hasClipboardText();

extern(C) void platformSetTextInputRect(in Rect rect);

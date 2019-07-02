module rpui.platform;

import std.conv;
import std.array;
import std.string;

import derelict.sdl2.sdl;
import derelict.sdl2.ttf;
import derelict.sdl2.image;

import gapi.opengl;

import rpui.events;
import rpui.events_observer;
import rpui.input;

struct Window {
    void* handle;
    void* gapiContext;
}

extern(C) void platformShowSystemCursor();

extern(C) void platformHideSystemCursor();

extern(C) void platformSetMousePosition(void* window, in int x, in int y);

extern(C) float platformGetTicks();

extern(C) bool platformEventLoop(EventsObserver events);

extern(C) void platformSwapWindow(void* window);

extern(C) void platformGapiDeleteContext(void* context);

extern(C) void platformDestroyWindow(void* window);

extern(C) void platformShutdown();

extern(C) void platformInit();

extern(C) Window platformCreateWindow(in string title, uint width, uint height);

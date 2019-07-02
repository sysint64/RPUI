module rpui.platform_glfw;

version(rpuiGlfw):

import std.string;

import rpui.events;
import rpui.platform;
import rpui.events_observer;

import gapi.opengl;
import derelict.sdl2.sdl;
import derelict.sdl2.ttf;
import derelict.sdl2.image;
import derelict.glfw3.glfw3;

extern(C) void platformInit() {
    // Load shared libraries
    DerelictGL3.load();
    DerelictSDL2.load();
    DerelictSDL2Image.load();
    DerelictSDL2TTF.load();
    DerelictGLFW3.load();

    // Init

    if (SDL_Init(SDL_INIT_VIDEO) < 0)
        throw new Error("Failed to init SDL");

    if (TTF_Init() < 0)
        throw new Error("Failed to init SDL TTF");

    if (!glfwInit())
        throw new Error("Failed to init GLFW3");

    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwSwapInterval(1);
}

extern(C) void platformShutdown() {
    glfwTerminate();
}

extern(C) Window platformCreateWindow(in string title, uint width, uint height) {
    auto window = glfwCreateWindow(width, height, toStringz(title), null, null);

    if (!window) {
        throw new Error("Failed to create window");
    }

    glfwMakeContextCurrent(window);
    DerelictGL3.reload();

    return Window(window, null);
}

extern(C) void platformDestroyWindow(void* window) {
    glfwDestroyWindow(cast(GLFWwindow*) window);
}

extern(C) void platformSwapWindow(void* window) {
    glfwSwapBuffers(cast(GLFWwindow*) window);
}

extern(C) float platformGetTicks() {
    return glfwGetTime() * 1000f;
}

extern(C) bool platformEventLoop(void* window, EventsObserver events) {
    int width;
    int height;

    glfwGetFramebufferSize(cast(GLFWwindow*) window, &width, &height);
    events.notify(WindowResizeEvent(width, height));

    glfwPollEvents();
    return !glfwWindowShouldClose(cast(GLFWwindow*) window);
}

extern(C) void platformShowSystemCursor() {
}

extern(C) void platformHideSystemCursor() {
}

extern(C) void platformSetMousePosition(void* window, in int x, in int y) {
}

extern(C) void platformGapiDeleteContext(void* context) {
}

module rpui.application;

import std.conv;
import std.array;
import std.string;

import derelict.sdl2.sdl;

import gapi.opengl;
import rpui.events;
import rpui.events_observer;
import rpui.input;
import rpui.cursor;
import rpui.primitives;
import rpui.platform;

abstract class Application : EventsListenerEmpty {
    struct WindowData {
        void* window;
        void* glContext;
        int viewportWidth = 1024;
        int viewportHeight = 768;
    }

    struct Times {
        float current = 0f;
        float delta = 0f;
        float last = 0f;
        immutable part = 1_000.0 / 60.0;
    }

    protected EventsObserver events;
    protected CursorManager cursorManager;

    protected WindowData windowData;
    private Times times;
    private bool isPlatformInit = false;

    this() {
        events = new EventsObserver();
        cursorManager = new CursorManager();
        events.subscribe(this);
    }

    ~this() {
        if (isPlatformInit) {
            platformGapiDeleteContext(windowData.glContext);
            platformDestroyWindow(windowData.window);
            platformShutdown();
        }
    }

    final void run() {
        initPlatform();
        initGL();
        onCreate();
        mainLoop();
    }

    override void onWindowResize(in WindowResizeEvent event) {
        windowData.viewportWidth = event.width;
        windowData.viewportHeight = event.height;
        glViewport(0, 0, event.width, event.height);
    }

    private void initPlatform() {
        platformInit();

        auto window = platformCreateWindow(
            "RPUI",
            windowData.viewportWidth,
            windowData.viewportHeight
        );

        windowData.window = window.handle;
        windowData.glContext = window.gapiContext;

        isPlatformInit = true;
    }

    private void initGL() {
        glDisable(GL_CULL_FACE);
        glDisable(GL_MULTISAMPLE);
        glDisable(GL_DEPTH_TEST);
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glClearColor(150.0f/255.0f, 150.0f/255.0f, 150.0f/255.0f, 0);
        glClear(GL_COLOR_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
    }

    private void mainLoop() {
        bool running = true;
        events.notify(WindowResizeEvent(windowData.viewportWidth, windowData.viewportHeight));

        while (running) {
            int width;
            int height;
            SDL_GetWindowSize(cast(SDL_Window*) windowData.window, &width, &height);

            windowData.viewportHeight = width;
            windowData.viewportHeight = height;

            times.current = platformGetTicks();
            running = platformEventLoop(windowData.window, events);
            render();
        }
    }

    private void render() {
        if (times.current >= times.last + times.part) {
            times.delta = (times.current - times.last) / 1000.0f;
            onProgress(ProgressEvent(times.delta));
            times.last = times.current;
            glClear(GL_COLOR_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
            onRender();
            platformSwapWindow(windowData.window);
        }
    }

    override void onWindowExposed(in WindowExposedEvent event) {
        // TODO(Andrey): test on windows
        // glViewport(0, 0, windowData.viewportWidth, windowData.viewportHeight);
        int width;
        int height;
        SDL_GetWindowSize(cast(SDL_Window*) windowData.window, &width, &height);

        windowData.viewportHeight = width;
        windowData.viewportHeight = height;

        onProgress(ProgressEvent(0));
        glClear(GL_COLOR_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
        onRender();
        platformSwapWindow(windowData.window);
    }

    void onRender() {
    }

    void onCreate() {
    }

    void onDestroy() {
    }

    void onProgress(in ProgressEvent event) {
    }
}

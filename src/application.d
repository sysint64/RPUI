module application;

import std.stdio;
import std.conv;
import std.path;
import std.file : thisExePath;
import std.concurrency;
import core.thread;

import derelict.opengl.gl;
import derelict.sdl2.image;
import derelict.sdl2.sdl;
import derelict.sdl2.ttf;

import gapi.opengl;

import basic_types: utf32char;
import input;
import log;
import settings;
import editor.mapeditor : MapEditor;
import math.linalg;

import gapi.shader;
import gapi.camera;
import rpui.cursor;
import rpui.events;
import rpui.events_observer;
import rpui.clipboard;
import rpui.clipboard_sfml;
import path;

abstract class Application {
    EventsObserver events;
    const Pathes pathes;
    private bool isCursorVisible = true;
    Clipboard clipboard = null;

    struct WindowData {
        SDL_Window* window;
        SDL_GLContext glContext;
        int viewportWidth = 1024;
        int viewportHeight = 768;
    }

    private WindowData windowData;

    this() {
        events = new EventsObserver();
        pathes = initPathes();
        clipboard = new SFMLClipboard();
    }

    static Application getInstance() {
        return MapEditor.getInstance();
    }

    final void run(in bool runLoop = true) {
        cursor = new Cursor();

        DerelictGL3.load();

        DerelictSDL2.load();
        DerelictSDL2Image.load();
        DerelictSDL2TTF.load();

        initSDL();
        initGL();

        p_settings = Settings.getInstance();
        settings.load(binDirectory, "settings.rdl");
        onCreate();

        if (runLoop) {
            loop();
        }

        stopSDL();
        // log = new Log();

        // writeln(settings.theme);
        // onCreate();
    }

    private void initSDL() {
        if (SDL_Init(SDL_INIT_VIDEO) < 0)
            throw new Error("Failed to init SDL");

        if (TTF_Init() < 0)
            throw new Error("Failed to init SDL TTF");

        SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 4);
        SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3);
        SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
        SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
        SDL_GL_SetSwapInterval(2);

        windowData.window = SDL_CreateWindow(
            "Simple data oriented GAPI",
            SDL_WINDOWPOS_CENTERED,
            SDL_WINDOWPOS_CENTERED,
            windowData.viewportWidth,
            windowData.viewportHeight,
            SDL_WINDOW_OPENGL | SDL_WINDOW_RESIZABLE
        );

        if (windowData.window == null)
            throw new Error("SDL Error: " ~ to!string(SDL_GetError()));

        windowData.glContext = SDL_GL_CreateContext(windowData.window);

        if (windowData.glContext == null)
            throw new Error("SDL Error: " ~ to!string(SDL_GetError()));

        SDL_GL_SwapWindow(windowData.window);

        DerelictGL3.reload();
    }

    private void stopSDL() {
        SDL_GL_DeleteContext(windowData.glContext);
        SDL_DestroyWindow(windowData.window);
        SDL_Quit();
        TTF_Quit();
    }

    void render() {}

    void logError(Char, T...)(in Char[] fmt, T args) {
        debug log.display(vec4(0.8f, 0.1f, 0.1f, 1), fmt, args);
    }

    void logWarning(Char, T...)(in Char[] fmt, T args) {
        debug log.display(vec4(0.1f, 0.1f, 0.8f, 1), fmt, args);
    }

    void logDebug(Char, T...)(in Char[] fmt, T args) {
        debug log.display(vec4(0.3f, 0.3f, 0.3f, 1), fmt, args);
    }

    void warning(Char, T...)(in Char[] fmt, T args) {
    }

    void error(Char, T...)(in Char[] fmt, T args) {
    }

    void criticalError(Char, T...)(in Char[] fmt, T args) {
        logError(fmt, args);
    }

    void hideCursor() {
        if (!isCursorVisible)
            return;

        // TODO:
        // sfWindow_setMouseCursorVisible(window, false);
        isCursorVisible = false;
    }

    void showCursor() {
        if (isCursorVisible)
            return;

        // TODO:
        // sfWindow_setMouseCursorVisible(window, true);
        isCursorVisible = true;
    }

    void setMousePositon(in int x, in int y) {
        // TODO:
        // sfMouse_setPosition(sfVector2i(x, y), window);
    }

    // Events
    void onCreate() {}

    void onProgress() {
    }

    void onPostRender(Camera camera) {
        log.render(camera);
    }

    void onPreRender(Camera camera) {}

    void onKeyPressed(in KeyCode key) {
        setKeyPressed(key, true);
        events.notify(KeyPressedEvent(key));
    }

    void onKeyReleased(in KeyCode key) {
        setKeyPressed(key, false);
        events.notify(KeyReleasedEvent(key));
    }

    void onTextEntered(in utf32char key) {
        events.notify(TextEnteredEvent(key));
    }

    void onMouseDown(in uint x, in uint y, in MouseButton button) {
        p_mouseButton = button;
        events.notify(MouseDownEvent(x, y, button));
    }

    void onMouseUp(in uint x, in uint y, in MouseButton button) {
        p_mouseButton = MouseButton.mouseNone;
        events.notify(MouseUpEvent(x, y, button));
    }

    void onDblClick(in uint x, in uint y, in MouseButton button) {
        events.notify(DblClickEvent(x, y, button));
    }

    void onMouseMove(in uint x, in uint y) {
        events.notify(MouseMoveEvent(x, y, to!MouseButton(p_mouseButton)));
    }

    void onMouseWheel(in int dx, in int dy) {
        events.notify(MouseWheelEvent(dx, dy));
    }

    void onResize(in uint width, in uint height) {
        p_windowWidth = width;
        p_windowHeight = height;
        events.notify(WindowResizeEvent(width, height));
        glViewport(0, 0, width, height);
        glClear(GL_COLOR_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
        render();
    }

    @property string binDirectory() { return pathes.bin; }
    @property string resourcesDirectory() { return pathes.resources; }
    @property string testsDirectory() { return pathes.tests; }
    @property Settings settings() { return p_settings; }

    @property uint screenWidth() { return p_screenWidth; }
    @property uint screenHeight() { return p_screenHeight; }
    @property uint windowWidth() { return p_windowWidth; }
    @property uint windowHeight() { return p_windowHeight; }
    @property uint viewportWidth() { return p_windowWidth; }
    @property uint viewportHeight() { return p_windowHeight; }

    @property vec2i mousePos() { return p_mousePos; }
    @property vec2i mouseClickPos() { return p_mouseClickPos; }
    @property uint mouseButton() { return p_mouseButton; }

    @property Shader lastShader() { return p_lastShader; }
    @property void lastShader(Shader shader) { p_lastShader = shader; }
    @property float deltaTime() { return p_deltaTime; }
    @property float currentTime() { return p_currentTime; }

    void setCursor(in Cursor.Icon val) {
        if (isCursorVisible)
            cursor.setIcon(val);
    }

    // @property sfWindowHandle windowHandle() { return p_windowHandle; }

private:
    // sfWindow* window;
    // sfWindowHandle p_windowHandle;
    Log log;

    Settings p_settings;

    // GAPI
    Shader p_lastShader = null;

    // Video
    uint p_screenWidth;
    uint p_screenHeight;
    uint p_windowWidth;
    uint p_windowHeight;

    // Cursor
    Cursor cursor;
    vec2i p_mousePos;
    vec2i p_mouseClickPos;
    uint p_mouseButton = MouseButton.mouseNone;

    // Time
    float p_deltaTime;
    float p_currentTime;
    float lastTime = 0;
    immutable partTime = 1_000.0 / 60.0;
    // sfClock* clock;

    // DblClick
    const dblClickThreshold = 0.3f * 1000.0f;
    float dblClickTimer = 0;
    bool clicked = false;

    void initGL() {
        glDisable(GL_CULL_FACE);
        glDisable(GL_MULTISAMPLE);
        glDisable(GL_DEPTH_TEST);
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glClearColor(150.0f/255.0f, 150.0f/255.0f, 150.0f/255.0f, 0);
    }

    void calculateTime() {
        // TODO:
        // const time = sfClock_getElapsedTime(clock);
        // p_currentTime = time.microseconds;
        // p_deltaTime = (p_currentTime - lastTime) * 0.001f;
        // lastTime = p_currentTime;
    }

    void loop() {
        bool running = true;

        void render() {
            if (currentTime >= lastTime + partTime) {
                p_deltaTime = (currentTime - lastTime) / 1000.0f;
                // onProgress();
                lastTime = currentTime;
                glClear(GL_COLOR_BUFFER_BIT);
                // this.render();
                SDL_GL_SwapWindow(windowData.window);
                // frames += 1;
            }
        }

        while (running) {
            p_currentTime = SDL_GetTicks();
            SDL_Event event;

            while (SDL_PollEvent(&event)) {
                if (event.type == SDL_QUIT) {
                    running = false;
                }

                if (event.type == SDL_WINDOWEVENT && event.window.event == SDL_WINDOWEVENT_SIZE_CHANGED) {
                    const width = event.window.data1;
                    const height = event.window.data2;

                    // cameraTransform.viewportSize.x = width;
                    // cameraTransform.viewportSize.y = height;
                    p_windowWidth = width;
                    p_windowHeight = height;

                    glViewport(0, 0, width, height);
                    SDL_GL_MakeCurrent(windowData.window, windowData.glContext);
                    render();
                    // SDL_GL_SwapWindow(windowData.window);
                }
            }

            render();

            // if (currentTime >= frameTime + 1000.0) {
            //     frameTime = currentTime;
            //     fps = frames;
            //     frames = 1;
            // }
        }

        // while (running) {
        //     auto mousePos = sfMouse_getPosition(window);
        //     p_mousePos = vec2i(mousePos.x, mousePos.y);
        //     calculateTime();
        //     sfEvent event;

        //     while (sfWindow_pollEvent(window, &event)) {
        //         if (event.type == sfEvtClosed) {
        //             running = false;
        //         } else {
        //             handleEvents(event);
        //         }
        //     }

        //     glViewport(0, 0, viewportWidth, viewportHeight);
        //     glClear(GL_COLOR_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);

        //     if (dblClickTimer > dblClickThreshold) {
        //         clicked = false;
        //         dblClickTimer = 0;
        //     } else if (clicked) {
        //         dblClickTimer += deltaTime;
        //     }

        //     onProgress();
        //     render();

        //     glFlush();
        //     sfWindow_display(window);

        //     Thread.sleep(dur!("msecs")(10));
        // }
    }

    // void handleEvents(in sfEvent event) {
    //     switch (event.type) {
    //         case sfEvtResized:
    //             onResize(event.size.width, event.size.height);
    //             break;

    //         case sfEvtTextEntered:
    //             onTextEntered(event.text.unicode);
    //             break;

    //         case sfEvtKeyPressed:
    //             try {
    //                 onKeyPressed(to!KeyCode(event.key.code));
    //             } catch(ConvException) {}

    //             break;

    //         case sfEvtKeyReleased:
    //             try {
    //                 onKeyReleased(to!KeyCode(event.key.code));
    //             } catch(ConvException) {}

    //             break;

    //         case sfEvtMouseButtonPressed:
    //             p_mouseClickPos = p_mousePos;

    //             with (event.mouseButton)
    //                 try {
    //                     onMouseDown(x, y, to!MouseButton(button));
    //                 } catch(ConvException) {}

    //             break;

    //         case sfEvtMouseButtonReleased:
    //             with (event.mouseButton)
    //                 try {
    //                     onMouseUp(x, y, to!MouseButton(button));

    //                     if (clicked) {
    //                         clicked = false;
    //                         dblClickTimer = 0;
    //                         onDblClick(x, y, to!MouseButton(button));
    //                     } else {
    //                         clicked = true;
    //                     }
    //                 } catch(ConvException) {}

    //             break;

    //         case sfEvtMouseMoved:
    //             onMouseMove(event.mouseMove.x, event.mouseMove.y);
    //             break;

    //         case sfEvtMouseWheelScrolled:
    //             const int delta = to!int(event.mouseWheelScroll.delta);

    //             switch (event.mouseWheelScroll.wheel) {
    //                 case sfMouseVerticalWheel:
    //                     onMouseWheel(0, delta);
    //                     break;

    //                 case sfMouseHorizontalWheel:
    //                     onMouseWheel(delta, 0);
    //                     break;

    //                 default:
    //                     break;
    //             }

    //             break;

    //         default:
    //             break;
    //     }
    // }
}

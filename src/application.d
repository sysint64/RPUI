module application;

import std.stdio;
import std.conv;
import std.path;
import std.file : thisExePath;
import std.concurrency;
import core.thread;

import derelict.sfml2.system;
import derelict.sfml2.window;
import derelict.opengl3.gl;

import basic_types: utfchar;
import input;
import log;
import settings;
import editor.mapeditor : MapEditor;
import math.linalg;

import gapi.shader;
import gapi.camera;
import ui.cursor;


abstract class Application {
    static Application getInstance() {
        return MapEditor.getInstance();
    }

    final void initPath() {
        p_binDirectory = dirName(thisExePath());
        p_resourcesDirectory = buildPath(p_binDirectory, "res");

        writeln(p_resourcesDirectory);
    }

    final void run(in bool runLoop = true) {
        p_cursor = new Cursor();

        initPath();
        initSFML();
        initGL();
        log = new Log();
        scope(exit) sfWindow_destroy(window);

        p_settings = Settings.getInstance();
        settings.load(binDirectory, "settings.rdl");

        writeln(settings.theme);
        onCreate();

        if (runLoop)
            loop();
    }

    void render() {}

    final void logError(Char, T...)(in Char[] fmt, T args) {
        debug log.display(vec4(0.8f, 0.1f, 0.1f, 1), fmt, args);
    }

    final void logWarning(Char, T...)(in Char[] fmt, T args) {
        debug log.display(vec4(0.1f, 0.1f, 0.8f, 1), fmt, args);
    }

    final void logDebug(Char, T...)(in Char[] fmt, T args) {
        debug log.display(vec4(0.3f, 0.3f, 0.3f, 1), fmt, args);
    }

    final void warning(Char, T...)(in Char[] fmt, T args) {

    }

    final void error(Char, T...)(in Char[] fmt, T args) {

    }

    final void criticalError(Char, T...)(in Char[] fmt, T args) {
        logError(fmt, args);
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
    }

    void onKeyReleased(in KeyCode key) {
        setKeyPressed(key, false);
    }

    void onTextEntered(in utfchar key) {}

    void onMouseDown(in uint x, in uint y, in MouseButton button) {
        p_mouseButton = button;
    }

    void onMouseUp(in uint x, in uint y, in MouseButton button) {
        p_mouseButton = MouseButton.mouseNone;
    }

    void onDblClick(in uint x, in uint y, in MouseButton button) {}
    void onMouseMove(in uint x, in uint y) {}
    void onMouseWheel(in int dx, in int dy) {}

    void onResize(in uint width, in uint height) {
        p_windowWidth = width;
        p_windowHeight = height;
    }

    @property string binDirectory() { return p_binDirectory; }
    @property string resourcesDirectory() { return p_resourcesDirectory; }
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

    @property Cursor.Icon cursor() { return p_cursor.icon; }
    @property void cursor(in Cursor.Icon val) { p_cursor.icon = val; }

    @property sfWindowHandle windowHandle() { return p_windowHandle; }

private:
    string p_binDirectory;
    string p_resourcesDirectory;
    sfWindow* window;
    sfWindowHandle p_windowHandle;
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
    Cursor p_cursor;
    vec2i p_mousePos;
    vec2i p_mouseClickPos;
    uint p_mouseButton = MouseButton.mouseNone;

    // Time
    float p_deltaTime;
    float p_currentTime;
    float lastTime = 0;
    sfClock *clock;

    void initSFML() {
        sfVideoMode desktomVideoMode = sfVideoMode_getDesktopMode();
        // TODO: uncomment, in my linux this return garbage
        // p_screenWidth  = desktomVideoMode.width;
        // p_screenHeight = desktomVideoMode.height;
        p_screenWidth = 9999;
        p_screenHeight = 9999;

        p_windowWidth  = 1024;
        p_windowHeight = 768;

        sfContextSettings settings;

        with (settings) {
            depthBits = 24;
            stencilBits = 8;
            antialiasingLevel = 0;
            majorVersion = 2;
            minorVersion = 1;
        }

        sfVideoMode videoMode = {windowWidth, windowHeight, 24};

        const(char)* title = "Simulator";
        window = sfWindow_create(videoMode, title, sfDefaultStyle, &settings);
        p_windowHandle = sfWindow_getSystemHandle(window);
        sfWindow_setVerticalSyncEnabled(window, false);
        sfWindow_setFramerateLimit(window, 60);

        DerelictGL.reload();
        clock = sfClock_create();
    }

    void initGL() {
        glDisable(GL_CULL_FACE);
        glDisable(GL_MULTISAMPLE);
        glDisable(GL_DEPTH_TEST);
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glClearColor(150.0f/255.0f, 150.0f/255.0f, 150.0f/255.0f, 0);
    }

    void calculateTime() {
        sfTime time = sfClock_getElapsedTime(clock);
        p_currentTime = time.microseconds;
        p_deltaTime = (p_currentTime - lastTime) * 0.001f;
        lastTime = p_currentTime;
    }

    void loop() {
        sfWindow_setActive(window, true);
        bool running = true;

        while (running) {
            auto mousePos = sfMouse_getPosition(window);
            p_mousePos = vec2i(mousePos.x, mousePos.y);
            calculateTime();
            sfEvent event;

            while (sfWindow_pollEvent(window, &event)) {
                if (event.type == sfEvtClosed) {
                    running = false;
                } else {
                    handleEvents(event);
                    onProgress();
                }
            }

            glViewport(0, 0, viewportWidth, viewportHeight);
            glClear(GL_COLOR_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);

            onProgress();
            render();

            glFlush();
            sfWindow_display(window);
        }
    }

    void handleEvents(in sfEvent event) {
        switch (event.type) {
            case sfEvtResized:
                onResize(event.size.width, event.size.height);
                break;

            case sfEvtTextEntered:
                onTextEntered(event.text.unicode);
                break;

            case sfEvtKeyPressed:
                try {
                    onKeyPressed(to!KeyCode(event.key.code));
                } catch(ConvException) {}

                break;

            case sfEvtKeyReleased:
                try {
                    onKeyReleased(to!KeyCode(event.key.code));
                } catch(ConvException) {}

                break;

            case sfEvtMouseButtonPressed:
                p_mouseClickPos = p_mousePos;

                with (event.mouseButton)
                    onMouseDown(x, y, to!MouseButton(button));

                break;

            case sfEvtMouseButtonReleased:
                with (event.mouseButton)
                    onMouseUp(x, y, to!MouseButton(button));

                break;

            case sfEvtMouseMoved:
                onMouseMove(event.mouseMove.x, event.mouseMove.y);
                break;

            case sfEvtMouseWheelScrolled:
                const int delta = to!int(event.mouseWheelScroll.delta);

                switch (event.mouseWheelScroll.wheel) {
                    case sfMouseVerticalWheel:
                        onMouseWheel(0, delta);
                        break;

                    case sfMouseHorizontalWheel:
                        onMouseWheel(delta, 0);
                        break;

                    default:
                        break;
                }

                break;

            default:
                break;
        }
    }
}

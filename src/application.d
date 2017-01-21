module application;

import std.stdio;
import std.conv;

import derelict.sfml2.system;
import derelict.sfml2.window;
import derelict.opengl3.gl;

import log;
import settings;
import editor.mapeditor : MapEditor;
import math.linalg;

import gapi.shader;
import gapi.camera;


abstract class Application {
    static Application getInstance() {
        return MapEditor.getInstance();
    }

    void run() {
        initSFML();
        initGL();
        log = new Log();
        scope(exit) sfWindow_destroy(window);

        auto settings = Settings.getInstance();
        settings.load(binDirectory, "settings.e2t");

        writeln(settings.uiTheme);
        onCreate();
        loop();
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

    // Events
    void onCreate() {}

    void onPostRender(Camera camera) {
        log.render(camera);
    }

    void onPreRender(Camera camera) {}

    void onKeyPressed(in uint key) {}
    void onKeyReleased(in uint key) {}
    void onTextEntered(in uint key) {}
    void onMouseDown(in uint x, in uint y, in uint button) {}
    void onMouseUp(in uint x, in uint y, in uint button) {}
    void onDblClick(in uint x, in uint y, in uint button) {}
    void onMouseMove(in uint x, in uint y) {}
    void onMouseWheel(in uint dx, in uint dy) {}

    void onResize(in uint width, in uint height) {
        p_windowWidth = width;
        p_windowHeight = height;
    }

    @property string binDirectory() { return p_binDirectory; }
    @property string resourcesDirectory() { return p_resourcesDirectory; }

    @property uint screenWidth() { return p_screenWidth; }
    @property uint screenHeight() { return p_screenHeight; }
    @property uint windowWidth() { return p_windowWidth; }
    @property uint windowHeight() { return p_windowHeight; }
    @property uint viewportWidth() { return p_windowWidth; }
    @property uint viewportHeight() { return p_windowHeight; }

    @property uint mouseX() { return p_mouseX; }
    @property uint mouseY() { return p_mouseY; }
    @property uint clickX() { return p_clickX; }
    @property uint clickY() { return p_clickY; }
    @property uint mouseButton() { return p_mouseButton; }

    @property Shader lastShader() { return p_lastShader; }
    @property void lastShader(Shader shader) { p_lastShader = shader; }
    @property float deltaTime() { return p_deltaTime; }
    @property float currentTime() { return p_currentTime; }

private:
    string p_binDirectory = "/home/andrey/projects/e2dit-dlang";  // TODO: rm hardcode
    string p_resourcesDirectory = p_binDirectory ~ "/res";  // TODO: rm hardcode
    sfWindow* window;
    Log log;

    // GAPI
    Shader p_lastShader = null;

    // Video
    uint p_screenWidth;
    uint p_screenHeight;
    uint p_windowWidth;
    uint p_windowHeight;

    // Cursor
    uint p_mouseX, p_mouseY;
    uint p_clickX, p_clickY;
    uint p_mouseButton;

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

        const(char)* title = "E2DIT";
        window = sfWindow_create(videoMode, title, sfDefaultStyle, &settings);
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
        bool running = true;

        while (running) {
            auto mousePos = sfMouse_getPosition(window);

            p_mouseX = mousePos.x;
            p_mouseY = mousePos.x;

            sfEvent event;

            while (sfWindow_pollEvent(window, &event)) {
                if (event.type == sfEvtClosed)
                    running = false;
                else
                    handleEvents(event);
            }

            calculateTime();
            sfWindow_setActive(window, true);

            glViewport(0, 0, viewportWidth, viewportHeight);
            glClear(GL_COLOR_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
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
                onKeyPressed(event.key.code);
                break;

            case sfEvtKeyReleased:
                onKeyReleased(event.key.code);
                break;

            case sfEvtMouseButtonPressed:
                with (event.mouseButton)
                    onMouseDown(x, y, button);

                break;

            case sfEvtMouseButtonReleased:
                with (event.mouseButton)
                    onMouseUp(x, y, button);

                break;

            case sfEvtMouseMoved:
                onMouseMove(event.mouseMove.x, event.mouseMove.y);
                break;

            case sfEvtMouseWheelScrolled:
                const uint delta = to!uint(event.mouseWheelScroll.delta);

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

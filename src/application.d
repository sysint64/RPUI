module application;

import settings;
import core.thread;
import std.stdio;
import patterns.singleton;
import derelict.sfml2.window;
import derelict.opengl3.gl3;


class Application {
    mixin Singleton!(Application);

    void run() {
        initSFML();
        initGL();
        scope(exit) sfWindow_destroy(window);

        auto settings = Settings.getInstance();
        settings.load(binDirectory, "settings.e2t");

        writeln(settings.uiTheme);
        loop();
    }

    @property string binDirectory() { return p_binDirectory; }
    @property uint screenWidth() { return p_screenWidth; }
    @property uint screenHeight() { return p_screenHeight; }
    @property uint windowWidth() { return p_windowWidth; }
    @property uint windowHeight() { return p_windowHeight; }

    @property uint mouseX() { return p_mouseX; }
    @property uint mouseY() { return p_mouseY; }
    @property uint clickX() { return p_clickX; }
    @property uint clickY() { return p_clickY; }
    @property uint mouseButton() { return p_mouseButton; }

private:
    string p_binDirectory = "C:/dev/e2dit";  // TODO: rm hardcode
    sfWindow* window;

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
    float deltaTime;
    float currentTime;

    void initSFML() {
        p_screenWidth  = sfVideoMode_getDesktopMode().width;
        p_screenHeight = sfVideoMode_getDesktopMode().height;

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

        DerelictGL3.reload();
    }

    void initGL() {
        glDisable(GL_CULL_FACE);
        glDisable(GL_MULTISAMPLE);
        glDisable(GL_DEPTH_TEST);
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glClearColor(150.0f/255.0f, 150.0f/255.0f, 150.0f/255.0f, 0);
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
                    handleEvents(event.type);
            }

            sfWindow_setActive(window, true);

            glViewport(0, 0, screenWidth, screenHeight);
            glClear(GL_COLOR_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
            glFlush();
            sfWindow_display(window);
        }
    }

    void handleEvents(sfEventType type) {
        switch (type) {
            case sfEvtResized:
                break;

            case sfEvtTextEntered:
                break;

            case sfEvtKeyPressed:
                break;

            case sfEvtKeyReleased:
                break;

            case sfEvtMouseWheelScrolled:
                break;

            case sfEvtMouseButtonPressed:
                break;

            case sfEvtMouseButtonReleased:
                break;

            case sfEvtMouseMoved:
                break;

            default:
                break;
        }
    }
}

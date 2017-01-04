module application;

import core.thread;
import std.stdio;
import patterns.singleton;
import derelict.sfml2.window;
import derelict.opengl3.gl3;


class Application {
    mixin Singleton!(Application);

    string binDirectory;

    // Video
    uint screenWidth;
    uint screenHeight;
    uint windowWidth;
    uint windowHeight;
    sfWindow* window;
    bool VAOEXT = false;

    // Cursor
    uint mouseX, mouseY;
    uint clickX, clickY;
    uint mouseButton;

    // Time
    float deltaTime;
    float currentTime;

    void initSFML() {
        sfContextSettings settings;
        settings.depthBits = 24;
        settings.stencilBits = 8;
        settings.antialiasingLevel = 0;
        settings.majorVersion = 2;
        settings.minorVersion = 1;

        sfVideoMode videoMode;
        videoMode.width = 1024;
        videoMode.height = 768;
        videoMode.bitsPerPixel = 24;

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

    void loop() {
        bool running = true;
        initSFML();
        initGL();

        scope(exit) sfWindow_destroy(window);

        while (running) {
            sfEvent event;

            while (sfWindow_pollEvent(window, &event)) {
                if (event.type == sfEvtClosed)
                    running = false;
                else
                    handleEvents(event.type);
            }

            sfWindow_setActive(window, true);

            glClear(GL_COLOR_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
            glFlush();

            sfWindow_display(window);
        }
    }
}

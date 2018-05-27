module test.core;

void initApp() {
    import application;

    import opengl;
    import derelict.freetype.ft;

    import derelict.sfml2.system;
    import derelict.sfml2.window;
    import derelict.sfml2.graphics;

    DerelictSFML2System.load();
    DerelictSFML2Window.load();
    DerelictSFML2Graphics.load();

    DerelictFT.load();
    DerelictGL3.load();

    auto app = Application.getInstance();
    app.run(false);
}

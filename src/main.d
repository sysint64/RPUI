module main;

import std.stdio;

import e2ml.data;
import e2ml.stream;
import e2ml.lexer;
import e2ml.token;
import e2ml.node;
import e2ml.value;

import derelict.opengl3.gl3;
import derelict.sfml2.system;
import derelict.sfml2.window;


void writeindent(in int level = 0) {
    for (int i = 0; i < level*4; ++i) {
        write(" ");
    }
}


void traverse(Node node, in int level = 0) {
    foreach (Node a; node.children) {
        writeindent(level);

        if (cast(Value)a)
            writeln(a.name ~ "(" ~ a.path ~ "): ", a.toString());
        else
            writeln(a.name ~ "(" ~ a.path ~ ")");

        traverse(a, level+1);
    }
}

void handleEvent(sfEventType type) {

}

void main() {
    DerelictSFML2System.load();
    DerelictSFML2Window.load();

    DerelictGL3.load();

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
    sfWindow* window = sfWindow_create(videoMode, title, sfDefaultStyle, &settings);
    sfWindow_setVerticalSyncEnabled(window, false);
    sfWindow_setFramerateLimit(window, 60);

    bool running = true;

    while (running) {
        sfEvent event;

        while (sfWindow_pollEvent(window, &event)) {
            if (event.type == sfEvtClosed)
                running = false;
            else
                handleEvent(event.type);
        }

        // Render

        sfWindow_setActive(window, true);
        sfWindow_display(window);
    }

    sfWindow_destroy(window);

    /// .....

    // DerelictGL3.reload();

    // Data data = new Data("/home/andrey/dev/e2dit-ml-dlang/tests");
    Data data = new Data("C:/dev/e2dit/tests");
    data.load("simple.e2t");

    writeln("\n\nTREE:\n");
    traverse(data.root);

    // data.getParameter("test.test2.p2");
    writeln(data.optNumber("test.test2.p2.12"));
    data.save("export.e2b", Data.IOType.text);
}

module main;

import std.stdio;
import editor.mapeditor;
import derelict.opengl.gl;

void main() {
    // DerelictSFML2System.load();
    // DerelictSFML2Window.load();
    // DerelictSFML2Graphics.load();

    // DerelictGL3.load();

    auto app = MapEditor.getInstance();
    app.run();
}

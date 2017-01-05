module main;

import std.stdio;

import e2ml.data;
import e2ml.stream;
import e2ml.lexer;
import e2ml.token;
import e2ml.node;
import e2ml.value;

import gapi.shader;
import gapi.texture;

import application;

import derelict.opengl3.gl3;
import derelict.sfml2.system;
import derelict.sfml2.window;
import derelict.sfml2.graphics;


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
    DerelictSFML2Graphics.load();

    DerelictGL3.load();

    auto app = Application.getInstance();
    app.run();

    // DerelictGL3.reload();

    // Data data = new Data("/home/andrey/dev/e2dit-ml-dlang/tests");
    Data data = new Data("C:/dev/e2dit/tests");
    data.load("simple.e2t");

    writeln("\n\nTREE:\n");
    traverse(data.root);

    // data.getParameter("test.test2.p2");
    writeln(data.optNumber("test.test2.p2.12"));
    data.save("export.e2b", Data.IOType.text);

    auto shader = new Shader("C:/dev/e2dit/res/shaders/GL2/transform.glsl");
    auto texture = new Texture("C:/dev/e2dit/res/ui/skins/light/controls.png");
}

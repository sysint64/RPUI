module main;

import std.stdio;

import rpdl.tree;
import rpdl.stream;
import rpdl.lexer;
import rpdl.token;
import rpdl.node;
import rpdl.value;

import gapi.shader;
import gapi.texture;

import rpui.widget;
import rpui.cursor;

import editor.mapeditor;

import derelict.opengl3.gl;
import derelict.freetype.ft;

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

        if (cast(Value) a)
            writeln(a.name ~ "(" ~ a.path ~ "): ", a.toString());
        else
            writeln(a.name ~ "(" ~ a.path ~ ")");

        traverse(a, level+1);
    }
}

void main() {
    DerelictSFML2System.load();
    DerelictSFML2Window.load();
    DerelictSFML2Graphics.load();

    DerelictFT.load();
    DerelictGL.load();

    auto app = MapEditor.getInstance();
    app.run();

    // Test
    // RpdlTree data = new RpdlTree("/home/andrey/projects/simulator/simulator/res/ui/layouts/");
    // data.load("test.rdl.bin", RpdlTree.FileType.bin);
    // data.save("test.rdl.txt", RpdlTree.FileType.text);
    // traverse(data.root);
}

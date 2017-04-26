module rpdl.tree;

import std.file;
import std.stdio;
import std.math;
import std.conv;
import std.path;
import std.traits;

import math.linalg;
import basic_types;

import rpdl.lexer;
import rpdl.parser;
import rpdl.stream;
import rpdl.node;
import rpdl.value;
import rpdl.exception;
import rpdl.writer;
import rpdl.accessors;

import gapi.texture;
import ui.widgets.panel.widget;
import ui.cursor;


class RPDLTree {
    enum IOType {text, bin};

    this() {
        p_root = new Node("");
    }

    this(in string rootDirectory) {
        this.p_rootDirectory = rootDirectory;
        p_root = new Node("");
    }

    void load(in string fileName, in IOType rt = IOType.text) {
        switch (rt) {
            case IOType.text: loadText(fileName); break;
            case IOType.bin: break;
            default:
                break;
        }
    }

    void save(in string fileName, in IOType wt = IOType.text) {
        Writer writer;

        switch (wt) {
            case IOType.text: writer = new TextWriter(p_root); break;
            case IOType.bin: writer = new BinWriter(p_root); break;
            default:
                return;
        }

        writer.save(fileName);
    }

    @property Node root() {
        return p_root;
    }

    @property string rootDirectory() {
        return p_rootDirectory;
    }

    void loadText(in string fileName) {
        SymbolStream stream = new SymbolStream(rootDirectory ~ dirSeparator ~ fileName);

        this.lexer  = new Lexer(stream);
        this.parser = new Parser(lexer, this);

        this.parser.parse();
    }

    // Access to nodes
    Node getNode(in string path) {
        return findNodeByPath(path, p_root);
    }

    mixin Accessors;

private:
    Lexer  lexer;
    Parser parser;

    string p_rootDirectory;
    Node p_root;

    Node getRootNode() {
        return p_root;
    }

    Node findNodeByPath(in string path, Node root) {
        assert(root !is null);

        foreach (Node child; root.children) {
            if (child.path == path)
                return child;

            Node node = findNodeByPath(path, child);

            if (node !is null)
                return node;
        }

        return null;
    }
}


unittest {
    Data data = new Data("/home/andrey/projects/e2dit-dlang/tests");
    data.load("simple.e2t");

    assert(data.getNumber("Test.Test2.p2.0") == 2);
    assert(data.getBoolean("Test.Test2.p2.1") == true);
    assert(data.getString("Test.Test2.p2.2") == "Hello");
    assert(data.getString("TestInclude.Linux.0") == "Arch");
    assert(data.getInteger("TestInclude.Test2.param.3.2") == 4);

    // Non standart types
    assert(data.getVec2f("Rombik.position") == vec2(1, 3));
    assert(data.getVec2i("Rombik.position") == vec2i(1, 3));
    assert(data.getVec2ui("Rombik.position") == vec2ui(1, 3));

    assert(data.getVec2f("Rombik.size.0") == vec2(320, 128));
    assert(data.getVec2f("Rombik.size2") == vec2(64, 1024));
    try { data.getVec2f("Rombik.size.1"); assert(false); } catch(NotVec2Exception) {}

    assert(data.getVec4f("Rombik.texCoord.0") == vec4(10, 15, 32, 64));
    assert(data.getVec4f("Rombik.texCoord2") == vec4(5, 3, 16, 24));

    assert(data.optVec4f("Rombik.texCoord2", vec4(0, 1, 2, 3)) == vec4(5, 3, 16, 24));
    assert(data.optVec4f("Rombik.texCoord3", vec4(0, 1, 2, 3)) == vec4(0, 1, 2, 3));
}

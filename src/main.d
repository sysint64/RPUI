module main;

import std.stdio;

import e2ml.data;
import e2ml.stream;
import e2ml.lexer;
import e2ml.token;
import e2ml.node;
import e2ml.value;


void writeindent(in int level = 0) {
    for (int i = 0; i < level*4; ++i) {
        write(" ");
    }
}


void traverse(ref Node node, in int level = 0) {
    foreach (Node a; node.children) {
        writeindent(level);

        if (cast(Value)a)
            writeln(a.name ~ "(" ~ a.path ~ "): ", a.toString());
        else
            writeln(a.name ~ "(" ~ a.path ~ ")");

        traverse(a, level+1);
    }
}


void main() {
    Data data = new Data();
    data.load("/home/andrey/dev/e2dit-ml-dlang/tests/simple.e2t");

    // writeln(data.getObject("Test.Test2.param.0.1").name);
    writeln("\n\nTREE:\n");
    traverse(data.root);
}

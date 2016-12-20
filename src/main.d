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


void main() {
    Data data = new Data("/home/andrey/dev/e2dit-ml-dlang/tests");
    data.load("simple.e2t");

    writeln("\n\nTREE:\n");
    traverse(data.root);

    // data.getParameter("test.test2.p2");
    writeln(data.optNumber("test.test2.p2.12"));
    data.save("", Data.IOType.bin);
}

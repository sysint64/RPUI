module main;

import std.stdio;

import e2ml.data;
import e2ml.stream;
import e2ml.lexer;
import e2ml.token;
import e2ml.node;


void main() {
    Data data = new Data();
    data.load("/home/andrey/dev/e2dit-ml-dlang/tests/simple.e2t");

    // writeln(data.getObject("Test.Test2").name);
    writeln("\nNODES:");

    foreach (Node a; data.parser.root.children) {
	writeln(a.name);
    }
}

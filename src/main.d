module main;

import std.stdio;

import e2ml.data;
import e2ml.stream;
import e2ml.lexer;
import e2ml.token;
import e2ml.node;


void traverse(ref Node node, in int level=0) {
    foreach (Node a; node.children) {
	for (int i = 0; i < level*4; ++i) {
	    write(" ");
	}

	writeln(a.name);
	traverse(a, level+1);
    }
}


void main() {
    Data data = new Data();
    data.load("/home/andrey/dev/e2dit-ml-dlang/tests/simple.e2t");

    // writeln(data.getObject("Test.Test2").name);
    writeln("\nNODES:");

    traverse(data.parser.root);
}

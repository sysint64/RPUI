module e2ml.data;

import std.file;
import std.stdio;

import e2ml.lexer;
import e2ml.parser;
import e2ml.stream;
import e2ml.node;


class Data {
    enum IOType {text, bin};

    void load(in string fileName, in IOType rt = IOType.text) {
        SymbolStream stream = new SymbolStream(fileName);

        this.lexer  = new Lexer(stream);
        this.parser = new Parser(lexer, stream);

        this.parser.parse();
    }

    Node getObject(in string path) {
	Node *object = path in objectMap;
	assert(object !is null, "Object is null");
	return *object;
    }

    Parser parser;

private:
    Lexer  lexer;


    Node[string] objectMap;
}

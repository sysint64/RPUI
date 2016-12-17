module e2ml.data;

import std.file;
import std.stdio;

import e2ml.lexer;
import e2ml.parser;
import e2ml.stream;
import e2ml.node;


class Data {
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

    Node getObject(in string path) {
        Node *object = path in objectMap;
        assert(object !is null, "Object is null");
        return *object;
    }

    @property Node root() {
        return p_root;
    }

    @property string rootDirectory() {
        return p_rootDirectory;
    }

    void loadText(in string fileName) {
        SymbolStream stream = new SymbolStream(rootDirectory ~ "/" ~ fileName);

        this.lexer  = new Lexer(stream);
        this.parser = new Parser(lexer, this);

        this.parser.parse();
    }

private:
    Lexer  lexer;
    Parser parser;

    Node[string] objectMap;
    string p_rootDirectory;
    Node p_root;
}

module e2ml.data;

import std.file;
import std.stdio;

import e2ml.lexer;
import e2ml.parser;
import e2ml.stream;
import e2ml.node;


class Data {
    enum IOType {text, bin};

    this() {}
    this(in string rootDirectory) {
        this.p_rootDirectory = rootDirectory;
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
        return parser.root;
    }

    @property string rootDirectory() {
        return p_rootDirectory;
    }

package:
    void loadText(in string fileName, Node root = null) {
        SymbolStream stream = new SymbolStream(rootDirectory ~ "/" ~ fileName);

        this.lexer  = new Lexer(stream);
        this.parser = new Parser(lexer, stream, root);

        this.parser.parse();
    }

private:
    Lexer  lexer;
    Parser parser;

    Node[string] objectMap;
    string p_rootDirectory;
}

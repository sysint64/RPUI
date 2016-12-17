module e2ml.data;

import std.file;
import std.stdio;

import e2ml.lexer;
import e2ml.parser;
import e2ml.stream;
import e2ml.node;
import e2ml.value;
import e2ml.exception;


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

    Node getNode(in string path) {
        return findNodeByPath(path);
    }

    ObjectNode getObject(in string path) {
        return getTypedNode!(ObjectNode, NotObjectException)(path);
    }

    Parameter getParameter(in string path) {
        return getTypedNode!(Parameter, NotParameterException)(path);
    }

    Value getValue(in string path) {
        return getTypedNode!(Value, NotValueException)(path);
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

    string p_rootDirectory;
    Node p_root;

    Node findNodeByPath(in string path, Node root = null) {
        if (root is null)
            root = this.p_root;

        foreach (Node child; root.children) {
            if (child.path == path)
                return child;

            Node node = findNodeByPath(path, child);

            if (node !is null)
                return node;
        }

        return null;
    }

    T getTypedNode(T : Node, E : E2TMLException)(in string path) {
        Node node = findNodeByPath(path);

        if (node is null)
            throw new NotFoundException("Node with path \"" ~ path ~ "\" not found");

        T object = cast(T)(node);

        if (object is null)
            throw new E("Node with path \"" ~ path ~ "\" is not an " ~ E.typeName);

        return cast(T)(node);
    }
}

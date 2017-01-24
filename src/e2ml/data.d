module e2ml.data;

import std.file;
import std.stdio;
import std.math;
import std.conv;

import math.linalg;

import e2ml.lexer;
import e2ml.parser;
import e2ml.stream;
import e2ml.node;
import e2ml.value;
import e2ml.exception;
import e2ml.writer;


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
        SymbolStream stream = new SymbolStream(rootDirectory ~ "/" ~ fileName);

        this.lexer  = new Lexer(stream);
        this.parser = new Parser(lexer, this);

        this.parser.parse();
    }

    // Access to nodes

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

    NumberValue getNumberValue(in string path) {
        return getTypedNode!(NumberValue, NotNumberValueException)(path);
    }

    StringValue getStringValue(in string path) {
        return getTypedNode!(StringValue, NotStringValueException)(path);
    }

    BooleanValue getBooleanValue(in string path) {
        return getTypedNode!(BooleanValue, NotBooleanValueException)(path);
    }

    ArrayValue getArrayValue(in string path) {
        return getTypedNode!(ArrayValue, NotArrayValueException)(path);
    }

    vec2 getVec2f(in string path) {
        ArrayValue vec = getArrayValue(path);

        if (vec !is null) {
            if (vec.length != 2)
                return vec2(0, 0);

            NumberValue x = cast(NumberValue)(vec.getAtIndex(0));
            NumberValue y = cast(NumberValue)(vec.getAtIndex(1));

            return vec2(x.value, y.value);
        }

        return vec2(0, 0);
    }

    // Optional access to nodes

    Node optNode(in string path, Node defaultVal = null) {
        Node node = findNodeByPath(path);

        if (node is null)
            return defaultVal;

        return node;
    }

    ObjectNode optObject(in string path, ObjectNode defaultVal = null) {
        return optTypedNode!(ObjectNode, NotObjectException)(path, defaultVal);
    }

    Parameter optParameter(in string path, Parameter defaultVal = null) {
        return optTypedNode!(Parameter, NotParameterException)(path, defaultVal);
    }

    Value optValue(in string path, Value defaultVal = null) {
        return optTypedNode!(Value, NotValueException)(path, defaultVal);
    }

    NumberValue optNumberValue(in string path, NumberValue defaultVal = null) {
        return optTypedNode!(NumberValue, NotNumberValueException)(path, defaultVal);
    }

    BooleanValue optBooleanValue(in string path, BooleanValue defaultVal = null) {
        return optTypedNode!(BooleanValue, NotBooleanValueException)(path, defaultVal);
    }

    StringValue optStringValue(in string path, StringValue defaultVal = null) {
        return optTypedNode!(StringValue, NotStringValueException)(path, defaultVal);
    }

    ArrayValue optArrayValue(in string path, ArrayValue defaultVal = null) {
        return optTypedNode!(ArrayValue, NotArrayValueException)(path, defaultVal);
    }

    // Access to values

    float getNumber(in string path) {
        return getTypedNode!(NumberValue, NotNumberValueException)(path).value;
    }

    int getInteger(in string path) {
        return to!int(getNumber(path));
    }

    bool getBoolean(in string path) {
        return getTypedNode!(BooleanValue, NotBooleanValueException)(path).value;
    }

    string getString(in string path) {
        return getTypedNode!(StringValue, NotStringValueException)(path).value;
    }

    dstring getUTFString(in string path) {
        return getTypedNode!(StringValue, NotStringValueException)(path).utfValue;
    }

    // Optional access to values

    float optNumber(in string path, float defaultVal = 0) {
        return optTypedValue!(float, NumberValue, NotNumberValueException)(path, defaultVal);
    }

    int optInteger(in string path, int defaultVal = 0) {
        return to!int(optNumber(path, to!float(defaultVal)));
    }

    bool optBoolean(in string path, bool defaultVal = false) {
        return optTypedValue!(bool, BooleanValue, NotBooleanValueException)(path, defaultVal);
    }

    string optString(in string path, string defaultVal = null) {
        return optTypedValue!(string, StringValue, NotStringValueException)(path, defaultVal);
    }

    dstring optUTFString(in string path, dstring defaultVal = null) {
        StringValue node = optTypedNode!(StringValue, NotStringValueException)(path, null);

        if (node is null)
            return defaultVal;

        return node.utfValue;
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

    // Helper methods for access to nodes and values by path
    T getTypedNode(T : Node, E : E2TMLException)(in string path) {
        Node node = findNodeByPath(path);

        if (node is null)
            throw new NotFoundException("Node with path \"" ~ path ~ "\" not found");

        T object = cast(T)(node);

        if (object is null)
            throw new E("Node with path \"" ~ path ~ "\" is not an " ~ E.typeName);

        return cast(T)(node);
    }

    T optTypedNode(T : Node, E : E2TMLException)(in string path, T defaultVal) {
        Node node = findNodeByPath(path);

        if (node is null)
            return defaultVal;

        T object = cast(T)(node);

        if (object is null)
            throw new E("Node with path \"" ~ path ~ "\" is not an " ~ E.typeName);

        return cast(T)(node);
    }

    T optTypedValue(T, N : Node, E : E2TMLException)(in string path, T defaultVal) {
        N node = optTypedNode!(N, E)(path, null);

        if (node is null)
            return defaultVal;

        return node.value;
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
    // assert(data.getVec2f("Rombik.position") == vec2(1, 3));
    // assert(data.getVec2i("Rombik.position") == vec2i(1, 3));
    // assert(data.getVec2ui("Rombik.position") == vec2ui(1, 3));

    auto vec = data.getVec2f("Rombik.size.0");
    writeln(vec);
    assert(data.getVec2f("Rombik.size.0") == vec2(320, 128));
    // assert(data.getVec2i("Rombik.size.0") == vec2i(320, 128));
    // assert(data.getVec2ui("Rombik.size.0") == vec2ui(320, 128));
}

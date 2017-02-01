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

    alias getObject = getTypedNode!(ObjectNode, NotObjectException);
    alias getParameter = getTypedNode!(Parameter, NotParameterException);
    alias getValue = getTypedNode!(Value, NotValueException);
    alias getNumberValue = getTypedNode!(NumberValue, NotNumberValueException);
    alias getStringValue = getTypedNode!(StringValue, NotStringValueException);
    alias getBooleanValue = getTypedNode!(BooleanValue, NotBooleanValueException);
    alias getArrayValue = getTypedNode!(ArrayValue, NotArrayValueException);

    alias getVec2f = getVecValue!(float, 2, NotVec2Exception);
    alias getVec3f = getVecValue!(float, 3, NotVec3Exception);
    alias getVec4f = getVecValue!(float, 4, NotVec4Exception);

    alias getVec2i = getVecValue!(int, 2, NotVec2Exception);
    alias getVec3i = getVecValue!(int, 3, NotVec3Exception);
    alias getVec4i = getVecValue!(int, 4, NotVec4Exception);

    alias getVec2ui = getVecValue!(uint, 2, NotVec2Exception);
    alias getVec3ui = getVecValue!(uint, 3, NotVec3Exception);
    alias getVec4ui = getVecValue!(uint, 4, NotVec4Exception);

    // Optional access to nodes

    Node optNode(in string path, Node defaultVal = null) {
        Node node = findNodeByPath(path);

        if (node is null)
            return defaultVal;

        return node;
    }

    alias optObject = optTypedNode!(ObjectNode, NotObjectException);
    alias optParameter = optTypedNode!(Parameter, NotParameterException);
    alias optValue = optTypedNode!(Value, NotValueException);
    alias optNumberValue = optTypedNode!(NumberValue, NotNumberValueException);
    alias optBooleanValue = optTypedNode!(BooleanValue, NotBooleanValueException);
    alias optStringValue = optTypedNode!(StringValue, NotStringValueException);
    alias optArrayValue = optTypedNode!(ArrayValue, NotArrayValueException);

    // Access to values

    alias getNumber = getTypedValue!(float, NumberValue, NotNumberValueException);
    alias getBoolean = getTypedValue!(bool, BooleanValue, NotBooleanValueException);
    alias getString = getTypedValue!(string, StringValue, NotStringValueException);

    dstring getUTFString(in string path) {
        return getTypedNode!(StringValue, NotStringValueException)(path).utfValue;
    }

    int getInteger(in string path) {
        return to!int(getNumber(path));
    }

    // Optional access to values

    alias optNumber = optTypedValue!(float, NumberValue, NotNumberValueException);
    alias optBoolean = optTypedValue!(bool, BooleanValue, NotBooleanValueException);
    alias optString = optTypedValue!(string, StringValue, NotStringValueException);

    dstring optUTFString(in string path, dstring defaultVal = dstring.init) {
        StringValue node = optTypedNode!(StringValue, NotStringValueException)(path, null);

        if (node is null)
            return defaultVal;

        return node.utfValue;
    }

    int optInteger(in string path, int defaultVal = 0) {
        return to!int(optNumber(path, to!float(defaultVal)));
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

    T getTypedValue(T, N : Node, E : E2TMLException)(in string path) {
        return getTypedNode!(N, E)(path).value;
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

    T optTypedValue(T, N : Node, E : E2TMLException)(in string path, T defaultVal = T.init) {
        N node = optTypedNode!(N, E)(path, null);

        if (node is null)
            return defaultVal;

        return node.value;
    }

    vec!(T, n) getVecValue(T, int n, E : E2TMLException)(in string path) {
        Node node = getNode(path);
        ArrayValue vecArray = cast(ArrayValue) node;

        if (vecArray !is null && vecArray.length != n)
            throw new E();

        NumberValue[n] vectorComponents;
        T[n] values;

        for (int i = 0; i < n; ++i) {
            vectorComponents[i] = cast(NumberValue) node.getAtIndex(i);

            if (vectorComponents[i] is null)
                throw new E();

            values[i] = to!T(vectorComponents[i].value);
        }

        return vec!(T, n)(values);
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
}

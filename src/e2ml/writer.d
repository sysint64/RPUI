module e2ml.writer;

import std.file;
import std.stdio;
import std.conv;

import e2ml.node;
import e2ml.value;


abstract class Writer {
    this(Node root) {
        this.root = root;
    }

    void save(in string fileName) {
        //this.file = File(fileName, "w");

        foreach (Node node; root.children) {
            writeObject(cast(ObjectNode)(node));
        }
    }

protected:
    Node root;
    File file;

    void rawWrite(in char[] buffer) {
        // file.rawWrite(buffer);
        write(buffer);
    }

    void rawWrite(in char ch) {
        //file.rawWrite([ch]);
        write(ch);
    }

    void rawWrite(string str) {
        //file.rawWrite(str);
        write(str);
    }

    void writeObject(ObjectNode object) {
    }

    void writeParameter(Parameter parameter) {
    }

    void writeValue(Value value) {
    }

    void writeNumber(NumberValue value) {
    }

    void writeBoolean(BooleanValue value) {
    }

    void writeString(StringValue value) {
    }

    void writeArray(ArrayValue array) {
    }
}


class TextWriter : Writer {
    this(Node root, in int indentSize = 4) { super(root); }

protected:
    int depth = 0;

    void writeIndent() {
        for (int i = 0; i < depth*4; ++i)
            rawWrite(' ');
    }

    override void writeObject(ObjectNode object) {
        writeIndent();
        rawWrite(object.name);
        rawWrite('\n');
        ++depth;

        foreach (Node child; object.children) {
            if (cast(Parameter)(child))
                writeParameter(cast(Parameter)(child));

            if (cast(ObjectNode)(child))
                writeObject(cast(ObjectNode)(child));
        }

        --depth;
    }

    override void writeParameter(Parameter parameter) {
        writeIndent();
        rawWrite(parameter.name);
        rawWrite(": ");
        int i = 0;

        foreach (Node child; parameter.children) {
            if (cast(Value)(child)) {
                ++i;
                writeValue(cast(Value)(child));

                if (i < parameter.children.length)
                    rawWrite(", ");
            }
        }

        rawWrite('\n');
    }

    override void writeValue(Value value) {
        if (cast(NumberValue)(value))
            writeNumber(cast(NumberValue)(value));

        if (cast(BooleanValue)(value))
            writeBoolean(cast(BooleanValue)(value));

        if (cast(StringValue)(value))
            writeString(cast(StringValue)(value));

        if (cast(ArrayValue)(value))
            writeArray(cast(ArrayValue)(value));
    }

    override void writeNumber(NumberValue node) {
        rawWrite(to!string(node.value));
    }

    override void writeBoolean(BooleanValue node) {
        rawWrite(to!string(node.value));
    }

    override void writeString(StringValue node) {
        rawWrite('"');
        rawWrite(node.value);
        rawWrite('"');
    }

    override void writeArray(ArrayValue array) {
        rawWrite("[");
        int i = 0;

        foreach (Node node; array.children) {
            ++i;
            writeValue(cast(Value)(node));

            if (i < array.children.length)
                rawWrite(", ");
        }

        rawWrite("]");
    }
}


class BinWriter : Writer {
    this(Node root) { super(root); }
}

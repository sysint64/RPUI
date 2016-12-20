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

    void rawWrite(in ubyte ch) {
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

    void writeNumberValue(NumberValue value) {
    }

    void writeBooleanValue(BooleanValue value) {
    }

    void writeStringValue(StringValue value) {
    }

    void writeArrayValue(ArrayValue array) {
    }
}


class TextWriter : Writer {
    this(Node root, in int indentSize = 4) {
        super(root);
        this.indentSize = indentSize;
    }

protected:
    int depth = 0;
    int indentSize = 0;

    void writeIndent() {
        for (int i = 0; i < depth*indentSize; ++i)
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
            writeNumberValue(cast(NumberValue)(value));

        if (cast(BooleanValue)(value))
            writeBooleanValue(cast(BooleanValue)(value));

        if (cast(StringValue)(value))
            writeStringValue(cast(StringValue)(value));

        if (cast(ArrayValue)(value))
            writeArrayValue(cast(ArrayValue)(value));
    }

    override void writeNumberValue(NumberValue node) {
        rawWrite(to!string(node.value));
    }

    override void writeBooleanValue(BooleanValue node) {
        rawWrite(to!string(node.value));
    }

    override void writeStringValue(StringValue node) {
        rawWrite('"');
        rawWrite(node.value);
        rawWrite('"');
    }

    override void writeArrayValue(ArrayValue array) {
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

protected:
    enum OpCode {
        none = 0x00,
        end = 0x01,
        object = 0x02,
        klass = 0x03,
        parameter = 0x04,
        numberValue = 0x05,
        booleanValue = 0x06,
        stringValue = 0x07,
        arrayValue = 0x08
    }

    void writeName(Node node) {
        rawWrite(cast(ubyte)(node.name.length));
        rawWrite(node.name);
    }

    void writeString(string str) {
        rawWrite(cast(ubyte)(str.length));
        rawWrite(str);
    }

    void writeOpCode(OpCode code) {
        rawWrite(cast(ubyte)(code));
    }

    override void writeObject(ObjectNode object) {
        writeOpCode(OpCode.object);
        writeName(object);

        foreach (Node child; object.children) {
            if (cast(Parameter)(child))
                writeParameter(cast(Parameter)(child));

            if (cast(ObjectNode)(child))
                writeObject(cast(ObjectNode)(child));
        }

        writeOpCode(OpCode.end);
    }

    override void writeParameter(Parameter parameter) {
        writeOpCode(OpCode.parameter);
        writeName(parameter);

        foreach (Node child; parameter.children) {
            if (cast(Value)(child))
                writeValue(cast(Value)(child));
        }

        writeOpCode(OpCode.end);
    }

    override void writeValue(Value value) {
        if (cast(NumberValue)(value))
            writeNumberValue(cast(NumberValue)(value));

        if (cast(BooleanValue)(value))
            writeBooleanValue(cast(BooleanValue)(value));

        if (cast(StringValue)(value))
            writeStringValue(cast(StringValue)(value));

        if (cast(ArrayValue)(value))
            writeArrayValue(cast(ArrayValue)(value));
    }

    override void writeNumberValue(NumberValue node) {
        writeOpCode(OpCode.numberValue);
        rawWrite(to!string(node.value));
    }

    override void writeBooleanValue(BooleanValue node) {
        writeOpCode(OpCode.booleanValue);
        rawWrite(to!string(node.value));
    }

    override void writeStringValue(StringValue node) {
        writeOpCode(OpCode.stringValue);
        writeString(node.value);
    }

    override void writeArrayValue(ArrayValue array) {
        writeOpCode(OpCode.arrayValue);

        foreach (Node node; array.children)
            writeValue(cast(Value)(node));

        writeOpCode(OpCode.end);
    }
}

module rpdl.writer;

import std.file;
import std.stdio;
import std.conv;

import rpdl.node;
import rpdl.value;
import rpdl.exception;


abstract class Writer {
    this(Node root) {
        this.root = root;
    }

    void save(in string fileName) {
        this.file = File(fileName, "w");

        foreach (Node node; root.children) {
            writeObject(cast(ObjectNode)(node));
        }
    }

protected:
    Node root;
    File file;

    void rawWrite(in ubyte ch) {
        file.rawWrite([ch]);
    }

    void rawWrite(in bool value) {
        file.rawWrite([value]);
    }

    void rawWrite(in int value) {
        file.rawWrite([value]);
    }

    void rawWrite(in float value) {
        file.rawWrite([value]);
    }

    void rawWrite(string str) {
        file.rawWrite(str);
    }

    void writeObject(ObjectNode object) {
        foreach (Node child; object.children) {
            if (cast(Parameter)(child)) {
                writeParameter(cast(Parameter)(child));
            } else if (cast(ObjectNode)(child)) {
                writeObject(cast(ObjectNode)(child));
            } else {
                throw new NotParameterOrValueException();
            }
        }
    }

    void writeParameter(Parameter parameter) {
        foreach (Node child; parameter.children) {
            if (cast(Value)(child)) {
                writeValue(cast(Value)(child));
            } else {
                throw new NotValueException();
            }
        }
    }

    void writeValue(Value value) {
        switch (value.type) {
            case Value.Type.Number:
                writeNumberValue(cast(NumberValue)(value));
                break;

            case Value.Type.Boolean:
                writeBooleanValue(cast(BooleanValue)(value));
                break;

            case Value.Type.String:
                writeStringValue(cast(StringValue)(value));
                break;

            case Value.Type.Array:
                writeArrayValue(cast(ArrayValue)(value));
                break;

            default:
                throw new WrongNodeType();
        }
    }

    void writeNumberValue(NumberValue value) {
    }

    void writeBooleanValue(BooleanValue value) {
    }

    void writeStringValue(StringValue value) {
    }

    void writeArrayValue(ArrayValue array) {
        foreach (Node node; array.children)
            writeValue(cast(Value)(node));
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
        super.writeObject(object);
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
        super.writeObject(object);
        writeOpCode(OpCode.end);
    }

    override void writeParameter(Parameter parameter) {
        writeOpCode(OpCode.parameter);
        writeName(parameter);
        super.writeParameter(parameter);
        writeOpCode(OpCode.end);
    }

    override void writeNumberValue(NumberValue node) {
        writeOpCode(OpCode.numberValue);
        rawWrite(node.value);
    }

    override void writeBooleanValue(BooleanValue node) {
        writeOpCode(OpCode.booleanValue);
        rawWrite(node.value);
    }

    override void writeStringValue(StringValue node) {
        writeOpCode(OpCode.stringValue);
        writeString(node.value);
    }

    override void writeArrayValue(ArrayValue array) {
        writeOpCode(OpCode.arrayValue);
        super.writeArrayValue(array);
        writeOpCode(OpCode.end);
    }
}

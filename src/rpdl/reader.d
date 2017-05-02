module rpdl.reader;

import std.file;
import std.stdio;
import std.conv;

import rpdl.node;
import rpdl.value;
import rpdl.exception;


abstract class Reader {
    this(Node root) {
        this.root = root;
    }

    void read(in string fileName) {
        this.file = File(fileName, "r");
        readObjects();
    }

protected:
    Node root;
    File file;

    void readObjects() {
    }
}


class BinReader : Reader {
    this(Node root) { super(root); }

protected:
    T rawRead(T)() {
        T[1] buf;
        file.rawRead(buf);
        return buf[0];
    }

    alias readByte = rawRead!ubyte;
    alias readBoolean = rawRead!bool;
    alias readNumber = rawRead!float;

    string readString(in ubyte length) {
        char[] buf = new char[length];
        file.rawRead(buf);
        return cast(string) buf;
    }

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
        identifierValue = 0x08,
        arrayValue = 0x09
    }

    override void readObjects() {
        ubyte opCode;

        while (opCode != OpCode.end) {
            opCode = readByte();

            if (opCode == OpCode.end)
                break;

            if (opCode != OpCode.object)
                assert(false);  // TODO: throw an exception

            readObject(root);
        }
    }

    void readObject(Node parent) {
        const ubyte nameLength = readByte();
        const string name = readString(nameLength);

        ObjectNode object = new ObjectNode(name);
        parent.insert(object);
        ubyte opCode = readByte();

        while (opCode != OpCode.end) {
            switch (opCode) {
                case OpCode.object:
                    readObject(object);
                    break;

                case OpCode.parameter:
                    readParameter(object);
                    break;

                default:
                    assert(false);  // TODO: throw an exception
            }

            opCode = readByte();
        }
    }

    void readParameter(Node parent) {
        const ubyte nameLength = readByte();
        const string name = readString(nameLength);

        Parameter parameter = new Parameter(name);
        parent.insert(parameter);

        ubyte opCode = readByte();

        while (opCode != OpCode.end) {
            readValue(parameter, opCode);
            opCode = readByte();
        }
    }

    void readArrayValue(Node parent) {
        const ubyte nameLength = readByte();
        const string name = readString(nameLength);

        ArrayValue arrayNode = new ArrayValue(name);
        parent.insert(arrayNode);

        ubyte opCode = readByte();

        while (opCode != OpCode.end) {
            readValue(arrayNode, opCode);
            opCode = readByte();
        }
    }

    void readValue(Node parent, in ubyte opCode) {
        switch (opCode) {
            case OpCode.numberValue:
                readNumberValue(parent);
                break;

            case OpCode.booleanValue:
                readBooleanValue(parent);
                break;

            case OpCode.stringValue:
                readStringValue(parent);
                break;

            case OpCode.identifierValue:
                readIdentifierValue(parent);
                break;

            case OpCode.arrayValue:
                readArrayValue(parent);
                break;

            default:
                assert(false);  // TODO: throw an exception
        }
    }

    void readNumberValue(Node parent) {
        const ubyte nameLength = readByte();
        const string name = readString(nameLength);
        const float value = readNumber();

        NumberValue valueNode = new NumberValue(name, value);
        parent.insert(valueNode);
    }

    void readBooleanValue(Node parent) {
        const ubyte nameLength = readByte();
        const string name = readString(nameLength);
        const bool value = readBoolean();

        BooleanValue valueNode = new BooleanValue(name, value);
        parent.insert(valueNode);
    }

    void readStringValue(Node parent) {
        const ubyte nameLength = readByte();
        const string name = readString(nameLength);

        const ubyte stringLength = readByte();
        const string value = readString(stringLength);
        const dstring utfValue = to!dstring(value);

        StringValue valueNode = new StringValue(name, value, utfValue);
        parent.insert(valueNode);
    }

    void readIdentifierValue(Node parent) {
        const ubyte nameLength = readByte();
        const string name = readString(nameLength);

        const ubyte stringLength = readByte();
        const string value = readString(stringLength);

        IdentifierValue valueNode = new IdentifierValue(name, value);
        parent.insert(valueNode);
    }
}

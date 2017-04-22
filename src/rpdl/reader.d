module rpdl.reader;

import std.file;
import std.stdio;

import rpdl.node;
import rpdl.value;
import rpdl.exception;


abstract class Reader {
    this(Node root) {
        this.root = root;
    }

    void load(in string fileName) {
        this.file = File(fileName, "r");
    }

protected:
    Node root;
    File file;

    void readObject(Node parent) {
    }

    void readParameter(Node parent) {
    }

    void readValue(Node parent) {
    }

    void readNumberValue(Node parent) {
    }

    void readBooleanValue(Node parent) {
    }

    void readStringValue(Node parent) {
    }

    void readArrayValue(Node parent) {
    }
}


class BinReader : Reader {
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
}

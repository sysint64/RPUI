module e2ml.value;

import std.container;
import e2ml.node;
import std.conv;


class Value: Node {
    enum Type {Number, String, Boolean, Array};

    this(in string name) { super(name); }
    this(in string name, Node) { super(name, parent); }

    @property Type type() { return p_type; }

protected:
    Type p_type;
}


class NumberValue: Value {
    @property float value() { return p_value; }

    this(in string name, in float value) {
        super(name);
        this.p_value = value;
        this.p_type = Type.Number;
    }

    override string toString() {
        return to!string(p_value);
    }

protected:
    float p_value;
}


class BooleanValue : Value {
    @property bool value() { return p_value; }

    this(in string name, in bool value) {
        super(name);
        this.p_value = value;
        this.p_type = Type.Boolean;
    }

    override string toString() {
        return to!string(p_value);
    }

private:
    bool p_value;
}


class StringValue : Value {
    @property string value() { return p_value; }
    @property dstring utfValue() { return p_utfValue; }

    this(in string name, in string value) {
        super(name);
        this.p_value = value;
        this.p_type = Type.String;
    }

    this(in string name, in string value, in dstring utfValue) {
        super(name);
        this.p_value = value;
        this.p_utfValue = utfValue;
        this.p_type = Type.String;
    }

    override string toString() {
        return to!string(p_value);
    }

private:
    string p_value;
    dstring p_utfValue;
}


class ArrayValue: Value {
    this(in string name) {
        super(name);
        this.p_type = Type.Array;
    }
}

module e2ml.value;

import std.container;
import e2ml.node;


class Value: Node {
    enum Type {Number, String, Boolean, Array};

    this(in string name) { super(name); }
    this(in string name, Node) { super(name, parent); }

protected:
    Type p_type;
}


class NumberValue: Value {
    @property float value() { return p_value; }

    this(in string name, in float value, Node parent) {
        super(name, parent);
        this.p_value = value;
        this.p_type = Type.Number;
    }

private:
    float p_value;
}


class BooleanValue: Value {
    @property bool value() { return p_value; }

    this(in string name, in bool value, Node parent) {
        super(name, parent);
        this.p_value = value;
        this.p_type = Type.Boolean;
    }

private:
    bool p_value;
}


class StringValue: Value {
    @property string value() { return p_value; }
    @property dstring urfValue() { return p_utfValue; }

    this(in string name, in string value, Node parent) {
        super(name, parent);
        this.p_value = value;
        this.p_type = Type.String;
    }

    this(in string name, in string value, in dstring utfValue, Node parent) {
        super(name, parent);
        this.p_value = value;
        this.p_utfValue = utfValue;
        this.p_type = Type.String;
    }

private:
    string p_value;
    dstring p_utfValue;
}


class ArrayValue: Value {
    @property Array!Value values() { return p_values; }

    this(in string name, Array!Value values, Node parent) {
        super(name, parent);
        this.p_values = values;
        this.p_type = Type.Array;
    }

private:
    Array!Value p_values;
}

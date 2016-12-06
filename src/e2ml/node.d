module e2ml.node;

import std.container;
import e2ml.value;


class Parameter {
    this(in string name, ref Array!Value values) {
        p_name   = name;
        p_parent = parent;
    }

    @property string name() { return p_name; }
    @property string path() { return p_path; }
    @property Node   parent() { return p_parent; }
    @property void name(ref string value) {
        p_name = value;
        updatePath();
    }

private:
    string p_name;
    string p_path;
    Node   p_parent;
    Array!Value p_values;

    void updatePath() {
        p_path = parent.path ~ "." ~ name;
    }
}


class Node {
    this(in string name) {
        this.p_name = name;
        this.p_path = name;
    }

    this(in string name, ref Node parent) {
        this.p_name = name;
        this.p_parameters = parameters;
        parent.insert(this);
        this.updatePath();
    }

    @property string name() { return p_name; }
    @property string path() { return p_path; }
    @property Node   parent() { return p_parent; }
    @property Array!Node children() { return p_children; }
    @property Array!Parameter parameters() { return p_parameters; }

    @property void name(ref string value) {
        p_name = value;
        updatePath();
    }

    void insertParameter(ref Parameter parameter) {
        assert(parameter !is null);
        p_parameters.insertBack(parameter);
        parameter.p_parent = this;
        parameter.updatePath();
    }

private:
    string p_name;
    string p_path;  // Key for find node

    Node p_parent;
    Array!Node p_children;
    Array!Parameter p_parameters;

    void insert(Node object) {
        p_children ~= object;
        object.p_parent = this;
    }

    void updatePath() {
        p_path = parent.path == "" ? name : parent.path ~ "." ~ name;
    }
}

module e2ml.node;

import std.container;
import e2ml.value;


class Node {
    this(in string name) {
        this.p_name = name;
        this.p_path = name;
    }

    this(in string name, Node parent) {
        this.p_name = name;
        parent.insert(this);
    }

    @property string name() { return p_name; }
    @property string path() { return p_path; }
    @property Node   parent() { return p_parent; }
    @property Array!Node children() { return p_children; }

    @property void name(in string value) {
        p_name = value;
        updatePath();
    }

    void insert(Node object) {
        p_children ~= object;
        object.p_parent = this;
        object.updatePath();
    }

protected:
    string p_name;
    string p_path;  // Key for find node

    Node p_parent;
    Array!Node p_children;

    void updatePath() {
        assert(parent !is null);
        p_path = parent.path == "" ? name : parent.path ~ "." ~ name;
    }
}


class Parameter: Node {
    this(in string name) { super(name); }
    this(in string name, Node parent) { super(name, parent); }
}

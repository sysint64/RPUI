module rpdl.node;

import std.stdio;
import std.container;
import std.traits;
import std.conv;

import math.linalg;
import basic_types;

import rpdl.value;
import rpdl.accessors;
import rpdl.exception;

import gapi.texture;
import ui.widgets.panel.widget;
import ui.cursor;


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
    @property size_t length() { return p_children.length; }

    @property void name(in string value) {
        p_name = value;
        updatePath();
    }

    Node getAtIndex(in size_t index) {
        return p_children[index];
    }

    void insert(Node object) {
        p_children ~= object;
        object.p_parent = this;
        object.updatePath();
    }

    Node getNode(in string relativePath) {
        return findNodeByPath(relativePath, this);
    }

    mixin Accessors;

protected:
    string p_name;
    string p_path;  // Key for find node
    alias p_root = this;

    Node p_parent;
    Array!Node p_children;

    void updatePath() {
        assert(parent !is null);
        p_path = parent.path == "" ? name : parent.path ~ "." ~ name;

        foreach (Node child; p_children)
            child.updatePath();
    }

private:
    Node getRootNode() {
        return this;
    }

    Node findNodeByPath(in string relativePath, Node root) {
        assert(root !is null);
        const string absolutePath = path ~ "." ~ relativePath;

        foreach (Node child; root.children) {
            if (child.path == absolutePath)
                return child;

            Node node = findNodeByPath(relativePath, child);

            if (node !is null)
                return node;
        }

        return null;
    }
}


class Parameter: Node {
    this(in string name) { super(name); }
    this(in string name, Node parent) { super(name, parent); }
}


class ObjectNode: Node {
    this(in string name) { super(name); }
    this(in string name, Node parent) { super(name, parent); }
}

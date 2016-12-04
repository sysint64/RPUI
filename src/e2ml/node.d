module e2ml.node;


class Parameter {

}


class Node {
    this(in string name) {
        this.name = name;
        this.path = name;
    }

    this(in string name, ref Node parent) {
        this.name = name;
        parent.insert(this);
    }

    string name;
    string path;  // Key for find node

    Node   parent;
    Node[] children;

    void insert(Node object) {
        children ~= object;
        object.path = path == "" ? object.name : path ~ "." ~ object.name;
    }
}

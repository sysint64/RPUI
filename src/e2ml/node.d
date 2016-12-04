module e2ml.node;


class Parameter {

}


class Node {
    this(in string name) {
        this.name = name;
    }

    string name;
    string path;
    Node[] children;

    void insert(Node object) {
	children ~= object;
    }
}

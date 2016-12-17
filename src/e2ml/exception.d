module e2ml.exception;


class E2TMLException : Exception {
    this() { super(""); }
    this(in string details) { super(details); }
}


class NotFoundException : E2TMLException {
    this() { super("not found"); }
    this(in string details) { super(details); }
}


class NotObjectException : E2TMLException {
    this() { super("it is not an object"); }
    this(in string details) { super(details); }
    static @property string typeName() { return "e2tml.node.ObjectNode"; }
}


class NotParameterException : E2TMLException {
    this() { super("it is not a parameter"); }
    this(in string details) { super(details); }
    static @property string typeName() { return "e2tml.node.Parameter"; }
}


class NotValueException : E2TMLException {
    this() { super("it is not a value"); }
    this(in string details) { super(details); }
    static @property string typeName() { return "e2tml.value.Value"; }
}

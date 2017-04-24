module rpdl.exception;


class RPDLException : Exception {
    this() { super(""); }
    this(in string details) { super(details); }
}


class NotFoundException : RPDLException {
    this() { super("not found"); }
    this(in string details) { super(details); }
}


class NotObjectException : RPDLException {
    this() { super("it is not an object"); }
    this(in string details) { super(details); }
    static @property string typeName() { return "ObjectNode"; }
}


class NotParameterException : RPDLException {
    this() { super("it is not a parameter"); }
    this(in string details) { super(details); }
    static @property string typeName() { return "Parameter"; }
}


class NotValueException : RPDLException {
    this() { super("it is not a value"); }
    this(in string details) { super(details); }
    static @property string typeName() { return "Value"; }
}


class NotParameterOrValueException : RPDLException {
    this() { super("it is not a parameter or value"); }
    this(in string details) { super(details); }
}


class NotNumberValueException : RPDLException {
    this() { super("it is not a number value"); }
    this(in string details) { super(details); }
    static @property string typeName() { return "NumberValue"; }
}


class NotBooleanValueException : RPDLException {
    this() { super("it is not a number value"); }
    this(in string details) { super(details); }
    static @property string typeName() { return "BooleanValue"; }
}


class NotStringValueException : RPDLException {
    this() { super("it is not a string value"); }
    this(in string details) { super(details); }
    static @property string typeName() { return "StringValue"; }
}


class NotIdentifierValueException : RPDLException {
    this() { super("it is not a identifier value"); }
    this(in string details) { super(details); }
    static @property string typeName() { return "IdentifierValue"; }
}


class NotArrayValueException : RPDLException {
    this() { super("it is not an array value"); }
    this(in string details) { super(details); }
    static @property string typeName() { return "ArrayValue"; }
}


class NotVec2Exception : RPDLException {
    this() { super("it is not a vec2 value"); }
    this(in string details) { super(details); }
}


class NotVec3Exception : RPDLException {
    this() { super("it is not a vec3 value"); }
    this(in string details) { super(details); }
}


class NotVec4Exception : RPDLException {
    this() { super("it is not a vec4 value"); }
    this(in string details) { super(details); }
}


class NotVec3OrVec4Exception : RPDLException {
    this() { super("it is not a vec3 or vec4 value"); }
    this(in string details) { super(details); }
}


class NotTextureCoordException : RPDLException {
    this() { super("it is not a texture coordinate value"); }
    this(in string details) { super(details); }
}


class NotAlignException : RPDLException {
    this() { super("it is not a align value"); }
    this(in string details) { super(details); }
}


class NotOrientationException : RPDLException {
    this() { super("it is not a orientation value"); }
    this(in string details) { super(details); }
}


class NotRegionAlignException : RPDLException {
    this() { super("it is not a region align value"); }
    this(in string details) { super(details); }
}


class NotVerticalAlignException : RPDLException {
    this() { super("it is not a vertical align value"); }
    this(in string details) { super(details); }
}


class NotPanelBackgroundException : RPDLException {
    this() { super("it is not a Panel.Background value"); }
    this(in string details) { super(details); }
}


class WrongNodeType : RPDLException {
    this() { super("wrong type of value"); }
    this(in string details) { super(details); }
}

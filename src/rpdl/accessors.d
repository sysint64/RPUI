module rpdl.accessors;


mixin template Accessors() {
    alias getObject = getTypedNode!(ObjectNode, NotObjectException);
    alias getParameter = getTypedNode!(Parameter, NotParameterException);
    alias getValue = getTypedNode!(Value, NotValueException);
    alias getNumberValue = getTypedNode!(NumberValue, NotNumberValueException);
    alias getStringValue = getTypedNode!(StringValue, NotStringValueException);
    alias getIdentifierValue = getTypedNode!(IdentifierValue, NotIdentifierValueException);
    alias getBooleanValue = getTypedNode!(BooleanValue, NotBooleanValueException);
    alias getArrayValue = getTypedNode!(ArrayValue, NotArrayValueException);

    alias getVec2f = getVecValue!(float, 2, NotVec2Exception);
    alias getVec3f = getVecValue!(float, 3, NotVec3Exception);
    alias getVec4f = getVecValue!(float, 4, NotVec4Exception);

    alias getVec2i = getVecValue!(int, 2, NotVec2Exception);
    alias getVec3i = getVecValue!(int, 3, NotVec3Exception);
    alias getVec4i = getVecValue!(int, 4, NotVec4Exception);

    alias getVec2ui = getVecValue!(uint, 2, NotVec2Exception);
    alias getVec3ui = getVecValue!(uint, 3, NotVec3Exception);
    alias getVec4ui = getVecValue!(uint, 4, NotVec4Exception);

    Texture.Coord getTexCoord(in string path) {
        Texture.Coord texCoord;
        vec4 coord = getVec4f(path);
        texCoord.offset = vec2(coord.x, coord.y);
        texCoord.size = vec2(coord.z, coord.w);
        return texCoord;
    }

    vec4 getNormColor(in string path) {
        vec4 color;

        try {
            color = getVec4f(path);
        } catch(NotVec4Exception) {
            vec3 color3 = getVec3f(path);
            color = vec4(color3, 100.0);
        } catch(NotVec3Exception) {
            throw new NotVec3OrVec4Exception();
        }

        color = vec4(color.r / 255.0f, color.g / 255.0f, color.b / 255.0f, color.a / 100.0f);
        return color;
    }

    // Optional access to nodes

    Node optNode(in string path, Node defaultVal = null) {
        Node node = findNodeByPath(path, getRootNode());

        if (node is null)
            return defaultVal;

        return node;
    }

    alias optObject = optTypedNode!(ObjectNode, NotObjectException);
    alias optParameter = optTypedNode!(Parameter, NotParameterException);
    alias optValue = optTypedNode!(Value, NotValueException);
    alias optNumberValue = optTypedNode!(NumberValue, NotNumberValueException);
    alias optStringValue = optTypedNode!(StringValue, NotStringValueException);
    alias optIdentifierValue = optTypedNode!(IdentifierValue, NotIdentifierValueException);
    alias optBooleanValue = optTypedNode!(BooleanValue, NotBooleanValueException);
    alias optArrayValue = optTypedNode!(ArrayValue, NotArrayValueException);

    // Access to values

    alias getNumber = getTypedValue!(float, NumberValue, NotNumberValueException);
    alias getBoolean = getTypedValue!(bool, BooleanValue, NotBooleanValueException);
    alias getString = getTypedValue!(string, StringValue, NotStringValueException);
    alias getIdentifier = getTypedValue!(string, IdentifierValue, NotIdentifierValueException);

    dstring getUTFString(in string path) {
        return getTypedNode!(StringValue, NotStringValueException)(path).utfValue;
    }

    int getInteger(in string path) {
        return to!int(getNumber(path));
    }

    // Optional access to values

    alias optNumber = optTypedValue!(float, NumberValue, NotNumberValueException);
    alias optBoolean = optTypedValue!(bool, BooleanValue, NotBooleanValueException);
    alias optString = optTypedValue!(string, StringValue, NotStringValueException);
    alias optIdentifier = optTypedValue!(string, IdentifierValue, NotIdentifierValueException);

    dstring optUTFString(in string path, dstring defaultVal = dstring.init) {
        StringValue node = optTypedNode!(StringValue, NotStringValueException)(path, null);

        if (node is null)
            return defaultVal;

        return node.utfValue;
    }

    int optInteger(in string path, int defaultVal = 0) {
        return to!int(optNumber(path, to!float(defaultVal)));
    }

    alias optVec2f = optVecValue!(float, 2, NotVec2Exception);
    alias optVec3f = optVecValue!(float, 3, NotVec3Exception);
    alias optVec4f = optVecValue!(float, 4, NotVec4Exception);

    alias optVec2i = optVecValue!(int, 2, NotVec2Exception);
    alias optVec3i = optVecValue!(int, 3, NotVec3Exception);
    alias optVec4i = optVecValue!(int, 4, NotVec4Exception);

    alias optVec2ui = optVecValue!(uint, 2, NotVec2Exception);
    alias optVec3ui = optVecValue!(uint, 3, NotVec3Exception);
    alias optVec4ui = optVecValue!(uint, 4, NotVec4Exception);


// TODO: encapsulate this non standart accessors to other module -----------------------------------

    Texture.Coord optTexCoord(in string path, Texture.Coord defaultVal = Texture.Coord.init) {
        Texture.Coord texCoord;

        try {
            vec4 coord = getVec4f(path);

            texCoord.offset = vec2(coord.x, coord.y);
            texCoord.size = vec2(coord.z, coord.w);

            return texCoord;
        } catch (NotFoundException) {
            return defaultVal;
        }
    }

    T getEnum(T, E : RPDLException)(in string path) {
        const string val = getIdentifier(path);

        foreach (immutable enumItem; [EnumMembers!T]) {
            if (to!string(enumItem) == val) {
                return enumItem;
            }
        }

        throw new E();
    }

    T optEnum(T, E : RPDLException)(in string path, in T defaultVal = T.init) {
        try {
            return getEnum!(T, E)(path);
        } catch (NotFoundException) {
            return defaultVal;
        }
    }

    alias getAlign = getEnum!(Align, NotAlignException);
    alias optAlign = optEnum!(Align, NotAlignException);

    alias getOrientation = getEnum!(Orientation, NotOrientationException);
    alias optOrientation = optEnum!(Orientation, NotOrientationException);

    alias getRegionAlign = getEnum!(RegionAlign, NotRegionAlignException);
    alias optRegionAlign = optEnum!(RegionAlign, NotRegionAlignException);

    alias getVerticalAlign = getEnum!(VerticalAlign, NotVerticalAlignException);
    alias optVerticalAlign = optEnum!(VerticalAlign, NotVerticalAlignException);

    alias getPanelBackground = getEnum!(Panel.Background, NotPanelBackgroundException);
    alias optPanelBackground = optEnum!(Panel.Background, NotPanelBackgroundException);

    alias getCursorIcon = getEnum!(Cursor.Icon, NotCursorIconException);
    alias optCursorIcon = optEnum!(Cursor.Icon, NotCursorIconException);

    Rect getRect(in string path) {
        return Rect(getVec4f(path));
    }

    Rect optRect(in string path, in Rect defaultVal = Rect.init) {
        try {
            return getRect(path);
        } catch (NotFoundException) {
            return defaultVal;
        }
    }

    FrameRect getFrameRect(in string path) {
        return FrameRect(getVec4f(path));
    }

    FrameRect optFrameRect(in string path, in FrameRect defaultVal = FrameRect.init) {
        try {
            return getFrameRect(path);
        } catch (NotFoundException) {
            return defaultVal;
        }
    }

    IntRect getIntRect(in string path) {
        return IntRect(getVec4i(path));
    }

    IntRect optIntRect(in string path, in IntRect defaultVal = IntRect.init) {
        try {
            return getIntRect(path);
        } catch (NotFoundException) {
            return defaultVal;
        }
    }

// Helper methods for access to nodes and values by path -------------------------------------------

    private T getTypedNode(T : Node, E : RPDLException)(in string path) {
        Node node = findNodeByPath(path, getRootNode());

        if (node is null)
            throw new NotFoundException("Node with path \"" ~ path ~ "\" not found");

        T object = cast(T)(node);

        if (object is null)
            throw new E("Node with path \"" ~ path ~ "\" is not an " ~ E.typeName);

        return cast(T)(node);
    }

    private T getTypedValue(T, N : Node, E : RPDLException)(in string path) {
        return getTypedNode!(N, E)(path).value;
    }

    private T optTypedNode(T : Node, E : RPDLException)(in string path, T defaultVal) {
        Node node = findNodeByPath(path, getRootNode());

        if (node is null)
            return defaultVal;

        T object = cast(T)(node);

        if (object is null)
            throw new E("Node with path \"" ~ path ~ "\" is not an " ~ E.typeName);

        return cast(T)(node);
    }

    private T optTypedValue(T, N : Node, E : RPDLException)(in string path, T defaultVal = T.init) {
        N node = optTypedNode!(N, E)(path, null);

        if (node is null)
            return defaultVal;

        return node.value;
    }

    private vec!(T, n) getVecValue(T, int n, E : RPDLException)(in string path) {
        Node node = getNode(path);

        if (node is null)
            throw new NotFoundException("Node with path \"" ~ path ~ "\" not found");

        return getVecValueFromNode!(T, n, E)(path, node);
    }

    private vec!(T, n) getVecValueFromNode(T, int n, E : RPDLException)(in string path, Node node) {
        if (node.length != n)
            throw new E();

        NumberValue[n] vectorComponents;
        T[n] values;

        for (int i = 0; i < n; ++i) {
            vectorComponents[i] = cast(NumberValue) node.getAtIndex(i);

            if (vectorComponents[i] is null)
                throw new E();

            values[i] = to!T(vectorComponents[i].value);
        }

        return vec!(T, n)(values);
    }

    private vec!(T, n) optVecValue(T, int n, E : RPDLException)(in string path,
        vec!(T, n) defaultVal = vec!(T, n).init)
    {
        Node node = findNodeByPath(path, getRootNode());

        if (node is null)
            return defaultVal;

        return getVecValueFromNode!(T, n, E)(path, node);
    }
}

module basic_rpdl_extensions;

import basic_types;
import rpdl.accessors;
import rpdl.exception;
import rpdl.node;

Rect getRect(Node node, in string path) {
    return Rect(node.getVec4f(path));
}

Rect optRect(Node node, in string path, in Rect defaultVal = Rect.init) {
    try {
        return node.getRect(path);
    } catch (NotFoundException) {
        return defaultVal;
    }
}

FrameRect getFrameRect(Node accessorNode, in string path) {
    Node node = accessorNode.getNode(path);

    if (node is null) {
        throw new NotFoundException("Node with path \"" ~ path ~ "\" not found");
    }

    if (node.length == 1) {
        const float val = accessorNode.getNumber(path ~ ".0");
        return FrameRect(val, val, val, val);
    }

    if (node.length == 2) {
        const float vertical = accessorNode.getNumber(path ~ ".0");
        const float horizontal = accessorNode.getNumber(path ~ ".1");
        return FrameRect(horizontal, vertical, horizontal, vertical);
    }

    if (node.length == 3) {
        const float top = accessorNode.getNumber(path ~ ".0");
        const float horizontal = accessorNode.getNumber(path ~ ".1");
        const float bottom = accessorNode.getNumber(path ~ ".2");
        return FrameRect(horizontal, top, horizontal, bottom);
    }

    return FrameRect(accessorNode.getVec4f(path));
}

FrameRect optFrameRect(Node node, in string path,
    in FrameRect defaultVal = FrameRect.init)
{
    try {
        return node.getFrameRect(path);
    } catch (NotFoundException) {
        return defaultVal;
    }
}

IntRect getIntRect(Node node, in string path) {
    return IntRect(node.getVec4i(path));
}

IntRect optIntRect(Node node, in string path, in IntRect defaultVal = IntRect.init) {
    try {
        return node.getIntRect(path);
    } catch (NotFoundException) {
        return defaultVal;
    }
}

module gapi.rpdl_extensions;

import math.linalg;
import gapi.texture;

import rpdl.node;
import rpdl.exception;

class NotTextureCoordException : RpdlException {
    this() { super("it is not a texture coordinate value"); }
    this(in string details) { super(details); }
}

Texture.Coord getTexCoord(Node node, in string path) {
    Texture.Coord texCoord;
    vec4 coord = node.getVec4f(path);
    texCoord.offset = vec2(coord.x, coord.y);
    texCoord.size = vec2(coord.z, coord.w);
    return texCoord;
}

Texture.Coord optTexCoord(Node node, in string path,
    Texture.Coord defaultVal = Texture.Coord.init)
{
    Texture.Coord texCoord;

    try {
        vec4 coord = node.getVec4f(path);

        texCoord.offset = vec2(coord.x, coord.y);
        texCoord.size = vec2(coord.z, coord.w);

        return texCoord;
    } catch (NotFoundException) {
        return defaultVal;
    }
}

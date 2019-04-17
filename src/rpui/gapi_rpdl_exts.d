module rpui.gapi_rpdl_exts;

import gapi.vec;
import gapi.texture;

import rpdl.node;
import rpdl.exception;

class NotTextureCoordException : RpdlException {
    this() { super("it is not a texture coordinate value"); }
    this(in string details) { super(details); }
}

Texture2DCoords getTexCoord(Node node, in string path) {
    Texture2DCoords texCoord;
    vec4 coord = node.getVec4f(path);
    texCoord.offset = vec2(coord.x, coord.y);
    texCoord.size = vec2(coord.z, coord.w);
    return texCoord;
}

Texture2DCoords optTexCoord(Node node, in string path,
    Texture2DCoords defaultVal = Texture2DCoords.init)
{
    Texture2DCoords texCoord;

    try {
        vec4 coord = node.getVec4f(path);

        texCoord.offset = vec2(coord.x, coord.y);
        texCoord.size = vec2(coord.z, coord.w);

        return texCoord;
    } catch (NotFoundException) {
        return defaultVal;
    }
}

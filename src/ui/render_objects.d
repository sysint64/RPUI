module ui.render_objects;

import gapi;
import math.linalg;
import std.container;


class BaseRenderObject : BaseObject {
    this(Geometry geometry) {
        super(geometry);
    }

    void addTexCoord(in string state, in Texture.Coord coord) {
        texCoordinates[state] = coord;
    }

    void addTexCoord(in string state, in Texture.Coord coord, Texture texture) {
        texCoordinates[state] = Texture.Coord.normalize(coord, texture);
    }

package:
    Texture.Coord[string] texCoordinates;
}


class TextRenderObject : Text {
    alias Text.Builder!TextRenderObject Builder;

    this(Geometry geometry) {
        super(geometry);
    }

    void addOffset(in string state, in vec2 offset) {
        offsets[state] = offset;
    }

    void addColor(in string state, in vec4 color) {
        colors[state] = color;
    }

package:
    vec2[string] offsets;
    vec4[string] colors;
}

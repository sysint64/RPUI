module ui.render_objects;

import gapi;
import math.linalg;
import std.container;


class BaseRenderObject : gapi.BaseObject {
    this(Geometry geometry) {
        super(geometry);
    }

    void addTexCoord(gapi.Texture.Coord coord) {
        texCoordinates.insert(coord);
    }

private:
    Array!(gapi.Texture.Coord) texCoordinates;
}


class TextRenderObject : gapi.Text {
    this(Geometry geometry) {
        super(geometry);
    }

    this(Geometry geometry, Font font) {
        super(geometry, font);
    }

    this(Geometry geometry, Font font, in vec4 color) {
        super(geometry, font, color);
    }

    this(Geometry geometry, Font font, in dstring text) {
        super(geometry, font, text);
    }

    this(Geometry geometry, Font font, in dstring text, in vec4 color) {
        super(geometry, font, text, color);
    }
}

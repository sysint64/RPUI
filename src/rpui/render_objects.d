/**
 * Additional render objects for rendering UI.
 *
 * Copyright: © 2017 Andrey Kabylin
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 */

module rpui.render_objects;

import gapi;
import math.linalg;
import std.container;
import optional;

/// Base renderable objects with additional information for render UI elements.
class BaseRenderObject : BaseObject {
    auto texture = no!Texture2D;

    /// Create with gerometry.
    this(Geometry geometry) {
        super(geometry);
    }

    /// Attach texture `coord` of skin texture for `state`.
    void addTexCoord(in string state, in Texture2DCoords coord) {
        texCoordinates[state] = coord;
    }

    /// Attach normalized texture `coord` of skin texture for `state`.
    void addTexCoord(in string state, in Texture2DCoords coord, Texture2D texture) {
        texCoordinates[state] = normilizeTexture2DCoords(coord, texture);
    }

    /// Attach single texture `coord` of skin texture.
    void setTexCoord(in Texture2DCoords coord) {
        texCoordinates["default"] = coord;
    }

    /// Attach normalized single texture `coord` of skin texture.
    void setTexCoord(in Texture2DCoords coord, Texture2D texture) {
        texCoordinates["default"] = normilizeTexture2DCoords(coord, texture);
    }

    vec2 getTextureSize(in string state) {
        return texCoordinates[state].size;
    }

package:
    Texture2DCoords[string] texCoordinates;
}

/// Text renderable object with additional information for UI.
class TextRenderObject : Text {
    alias Builder = Text.Builder!TextRenderObject;

    this(Geometry geometry) {
        super(geometry);
    }

    /// Attach text `offset` to `state`.
    void addOffset(in string state, in vec2 offset) {
        offsets[state] = offset;
    }

    /// Attach `color` to `state`.
    void addColor(in string state, in vec4 color) {
        colors[state] = color;
    }

    /// Get offset for `state`.
    vec2 getOffset(in string state) {
        return offsets[state];
    }

    /// Get color for `state`.
    vec4 getColor(in string state) {
        return colors[state];
    }

private:
    vec2[string] offsets;
    vec4[string] colors;
}

module rpui.render.components;

import std.algorithm;

import gapi.geometry;
import gapi.geometry_quad;
import gapi.texture;
import gapi.shader;
import gapi.vec;
import gapi.transform;
import gapi.text;
import gapi.font;

import rpui.primitives;

struct CameraView {
    mat4 mvpMatrix;
    float viewportWidth;
    float viewportHeight;
    float scaleX;
    float scaleY;

    @property inout(float) fontScale() inout { return scaleY; }
}

struct Geometry {
    Buffer indicesBuffer;
    Buffer verticesBuffer;
    Buffer texCoordsBuffer;

    VAO vao;
}

struct LinesGeometry {
    Buffer indicesBuffer;
    Buffer verticesBuffer;
    uint pointsCount;

    VAO vao;
}

struct QuadTransforms {
    Transform2D transform;
    mat4 modelMatrix;
    mat4 mvpMatrix;
}

struct LinesTransforms {
    Transform2D transform;
    mat4 modelMatrix;
    mat4 mvpMatrix;
}

// TODO(Andrey): Rename to ChainTransforms
struct HorizontalChainTransforms {
    QuadTransforms[ChainPart] quadTransforms;
}

struct TextureQuad {
    Geometry geometry;
    Texture2D texture;
}

struct TexAtlasTextureQuad {
    Geometry geometry;
    Texture2D texture;
    OriginalWithNormilizedTextureCoords texCoords;
}

struct StatefulTexAtlasTextureQuad {
    Geometry geometry;
    Texture2D texture;
    OriginalWithNormilizedTextureCoords[State] texCoords;
    State state;

    @property inout(OriginalWithNormilizedTextureCoords) currentTexCoords() inout {
        return texCoords[state];
    }
}

struct OriginalWithNormilizedTextureCoords {
    Texture2DCoords originalTexCoords;
    Texture2DCoords normilizedTexCoords;
}

struct StatefulChain {
    TextureQuad[ChainPart] parts;
    float[ChainPart] widths;
    Texture2DCoords[ChainPart][State] texCoords;
    State state;
}

struct Chain {
    TextureQuad[ChainPart] parts;
    float[ChainPart] widths;
    float height;
    Texture2DCoords[ChainPart] texCoords;
}

struct Block {
    float[ChainPart][BlockRow] widths;
    float[BlockRow] heights;

    Chain topChain;
    Chain middleChain;
    Chain bottomChain;
}

struct BlockTransforms {
    HorizontalChainTransforms topChain;
    HorizontalChainTransforms middleChain;
    HorizontalChainTransforms bottomChain;
}

struct UiTextRender {
    Geometry geometry;
    Text text;
    Texture2D texture;
}

struct StatefulUiText {
    UiTextRender render;
    UiTextAttributes[State] attrs;
    State state;
}

struct UiText {
    UiTextRender render;
    UiTextAttributes attrs;
}

struct UiTextAttributes {
    vec4 color;
    vec2 offset;
    int fontSize;
    dstring caption;
    Align textAlign = Align.center;
    VerticalAlign textVerticalAlign = VerticalAlign.middle;
    Font font;
}

struct UiTextTransforms {
    vec2 size;
    vec2 relativePosition;
    mat4 mvpMatrix;
    dstring cachedString = "";
}

enum State {
    leave,
    enter,
    click,
}

enum ChainPart {
    left,
    center,
    right,
    top,
    middle,
    bottom,
}

enum BlockRow {
    top,
    middle,
    bottom,
}

immutable horizontalChainParts = [
    ChainPart.left,
    ChainPart.center,
    ChainPart.right,
];

immutable verticalChainParts = [
    ChainPart.top,
    ChainPart.middle,
    ChainPart.bottom,
];

string getStateRdplName(in State state) {
    switch (state) {
        case State.leave:
            return "Leave";

        case State.enter:
            return "Enter";

        case State.click:
            return "Click";

        default:
            throw new Error("Unknown state");
    }
}

string getChainPartRdplName(in ChainPart part) {
    switch (part) {
        case ChainPart.left:
            return "left";

        case ChainPart.center:
            return "center";

        case ChainPart.right:
            return "right";

        case ChainPart.top:
            return "top";

        case ChainPart.middle:
            return "middle";

        case ChainPart.bottom:
            return "bottom";

        default:
            throw new Error("Unknown part");
    }
}

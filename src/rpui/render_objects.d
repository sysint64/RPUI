module rpui.render_objects;

import gapi.geometry;
import gapi.geometry_quad;
import gapi.texture;
import gapi.shader;
import gapi.vec;
import gapi.transform;

struct CameraView {
    mat4 mvpMatrix;
    float viewportWidth;
    float viewportHeight;
}

struct Geometry {
    Buffer indicesBuffer;
    Buffer verticesBuffer;
    Buffer texCoordsBuffer;

    VAO vao;
}

struct StatefulTextureQuad {
    Geometry geometry;
    Transform2D transform;
    mat4 modelMatrix;
    mat4 mvpMatrix;
    Texture2D texture;
    Texture2DCoords[State] texCoords;
}

struct TextureQuad {
    Geometry geometry;
    Transform2D transform;
    mat4 modelMatrix;
    mat4 mvpMatrix;
    Texture2D texture;
    Texture2DCoords texCoords;
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
}

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

        default:
            throw new Error("Unknown part");
    }
}

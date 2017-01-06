module gapi.sprite;

import gapi.geometry;
import derelict.opengl3.gl3;
import gl3n.linalg;


class SpriteGeometry: Geometry {
    this(in bool dynamic = false, in bool center = true, in bool strip = false) {
        GLuint renderMode = strip ? GL_TRIANGLE_STRIP : GL_TRIANGLES;
        this.center = center;
        this.strip = strip;
        super(dynamic, renderMode);
    }

    override void init() {
        if (center) {
            addVertex(vec2(-0.5f, -0.5f), vec2(0.0f, 1.0f));
            addVertex(vec2( 0.5f, -0.5f), vec2(1.0f, 1.0f));
            addVertex(vec2( 0.5f,  0.5f), vec2(1.0f, 0.0f));
            addVertex(vec2(-0.5f,  0.5f), vec2(0.0f, 0.0f));
        } else {
            addVertex(vec2(0.0f, 0.0f), vec2(0.0f, 1.0f));
            addVertex(vec2(1.0f, 0.0f), vec2(1.0f, 1.0f));
            addVertex(vec2(1.0f, 1.0f), vec2(1.0f, 0.0f));
            addVertex(vec2(0.0f, 1.0f), vec2(0.0f, 0.0f));
        }

        if (strip) {
            addIndices([0, 3, 1, 2]);
        } else {
            addIndices([0, 3, 1, 2, 3, 1]);
        }
    }

private:
    bool center;
    bool strip;
}

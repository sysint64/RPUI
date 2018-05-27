module gapi.lines_render_object;

import gapi.geometry;
import opengl;
import gl3n.linalg;

final class LinesRenderObject {
    this(in bool dynamic, in bool loop = false) {
        geometry = new Geometry(dynamic, loop ? GL_LINE_LOOP : GL_LINES);
    }

    void addVertex(in vec2 vertex) {
        geometry.addVertex(vertex);
    }

    void createGeometry() {
        geometry.createGeometry();
    }

    void updateGeometry() {
    }

    void clearGeometry() {
    }

private:
    Geometry geometry;
}

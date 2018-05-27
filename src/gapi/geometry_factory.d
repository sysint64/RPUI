module gapi.geometry_factory;

import patterns.singleton;
import gapi.geometry;
import opengl;
import gl3n.linalg;

class GeometryFactory {
    static Geometry createSprite(in bool dynamic = false, in bool center = false,
                                 in bool strip = true)
    {
        const GLuint renderMode = strip ? GL_TRIANGLE_STRIP : GL_TRIANGLES;
        Geometry spriteGeometry = new Geometry(dynamic, renderMode);

        with (spriteGeometry) {
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

        spriteGeometry.createGeometry();
        return spriteGeometry;
    }
}

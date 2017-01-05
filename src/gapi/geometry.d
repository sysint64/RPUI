module gapi.geometry;

import settings;
import std.container;
import derelict.opengl3.gl;
import derelict.opengl3.gl3;
import gl3n.linalg;


class Geometry {
    this(in bool dynamic = false, in GLuint renderMode = GL_TRIANGLES) {
        this.dynamic = dynamic;
        this.renderMode = renderMode;
        this.settings = Settings.getInstance();
    }

    ~this() {
        glDeleteBuffers(1, &verticesId);
        glDeleteBuffers(1, &texCoordsId);
        glDeleteBuffers(1, &indicesId);
    }

    void render() {
        if (!vboCreated)
            createVBO();

        renderElements();
    }

    void bind() {
        if (!vboCreated)
            createVBO();

        if (settings.VAOEXT) {
            glBindVertexArray(VAO);
            glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indicesId);
        } else {
            bindBuffers();
        }
    }

    void addVertex(in float x, in float y) {
        vertices.insert(vec2(x, y));
    }

    void addVertex(in float x, in float y, in float s, in float t) {
        vertices.insert(vec2(x, y));
        texCoords.insert(vec2(s, t));
    }

    void addVertex(in vec2 vertex) {
        vertices.insert(vertex);
    }

    void addVertex(in vec2 vertex, in vec2 texCoord) {
        vertices.insert(vertex);
        texCoords.insert(texCoord);
    }

    void addIndex(in GLuint index) {
        indices.insert(index);
    }

protected:
    void renderElements() {
        glDrawElements(renderMode, indices.length, GL_UNSIGNED_INT, null);
    }

private:
    Settings settings;
    GLuint verticesId;
    GLuint texCoordsId;
    GLuint indicesId;
    GLuint VAO;

    Array!vec2 vertices;
    Array!vec2 texCoords;
    Array!GLuint indices;

    bool vboCreated = false;
    bool dynamic;
    GLuint renderMode;

    void createVBO() {
        // Vertex buffer
        glGenBuffers(1, &verticesId);
        glBindBuffer(GL_ARRAY_BUFFER, verticesId);

        const int verticesSize = GLfloat.sizeof*2*vertices.length;

        if (!dynamic) {
            // Static object
            glBufferData(GL_ARRAY_BUFFER, verticesSize, &vertices[0], GL_STATIC_DRAW);
        } else {
            // Dynamic geometry (can change topology)
            glBufferData(GL_ARRAY_BUFFER, verticesSize, null, GL_STREAM_DRAW);
            glBufferSubData(GL_ARRAY_BUFFER, 0, verticesSize, &vertices[0]);
        }

        // Texture coordinates buffer
        glGenBuffers(1, &texCoordsId);
        glBindBuffer(GL_ARRAY_BUFFER, texCoordsId);

        const int texCoordsSize = GLfloat.sizeof*2*texCoords.length;
        glBufferData (GL_ARRAY_BUFFER, texCoordsSize, &texCoords[0], GL_STATIC_DRAW);

        // Indices buffer
        glGenBuffers(1, &indicesId);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indicesId);

        const int indicesSize = GLuint.sizeof*indices.length;
        glBufferData (GL_ELEMENT_ARRAY_BUFFER, indicesSize, &indices[0], GL_STATIC_DRAW);

        //auto settings = Settings.getInstance();

        if (settings.VAOEXT) {
            if (settings.OGLMajor >= 3) createVAO_33();
            else createVAO_21();
        }

        vboCreated = true;
    }

    // Binding buffers without VAO
    void bindBuffers() {
        // Texture coordinates
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
        glBindBuffer(GL_ARRAY_BUFFER, texCoordsId);
        glTexCoordPointer(2, GL_FLOAT, 0, null);

        // Vertices
        const int verticesSize = GLfloat.sizeof*2*vertices.length;
        glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, verticesSize, null);

        glEnableClientState(GL_VERTEX_ARRAY);
        glBindBuffer(GL_ARRAY_BUFFER, verticesId);
        glVertexPointer(2, GL_FLOAT, 0, null);

        // Indices
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indicesId);
    }

    void createVAO_21() {
        glGenVertexArrays(1, &VAO);
        glBindVertexArray(VAO);

        const int verticesSize = GLfloat.sizeof*2*vertices.length;
        glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, verticesSize, null);

        // Vertices
        glEnableClientState(GL_VERTEX_ARRAY);
        glBindBuffer(GL_ARRAY_BUFFER, verticesId);
        glVertexPointer(2, GL_FLOAT, 0, null);

        // Texture coordinates
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
        glBindBuffer(GL_ARRAY_BUFFER, texCoordsId);
        glTexCoordPointer(2, GL_FLOAT, 0, null);
    }

    void createVAO_33() {
        enum AttrLocation {
            in_Position = 0,
            in_TextCoords = 1,
        }

        glGenVertexArrays(1, &VAO);
        glBindVertexArray(VAO);

        // Vertices
        glBindBuffer(GL_ARRAY_BUFFER, verticesId);
        glEnableVertexAttribArray(AttrLocation.in_Position);
        glVertexAttribPointer(AttrLocation.in_Position, 2, GL_FLOAT, GL_FALSE, 0, null);

        // Texture coordinates
        glBindBuffer(GL_ARRAY_BUFFER, texCoordsId);
        glEnableVertexAttribArray(AttrLocation.in_TextCoords);
        glVertexAttribPointer(AttrLocation.in_TextCoords, 2, GL_FLOAT, GL_FALSE, 0, null);
    }
}

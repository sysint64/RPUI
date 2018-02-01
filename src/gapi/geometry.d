module gapi.geometry;

import settings;
import std.container;
import std.conv;
import derelict.opengl3.gl;
import std.stdio;
import gl3n.linalg;

final class Geometry {
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

    void createGeometry() {
        createVBO();
    }

    void render() {
        glDrawElements(renderMode, to!int(indices.length), GL_UNSIGNED_INT, null);
    }

    void bind() {
        if (settings.VAOEXT) {
            glBindVertexArray(VAO);
            glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indicesId);
        } else {
            bindBuffers();
        }
    }

    void unbind() {
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
        texCoords.insert(vec2(0, 0));
    }

    void addVertex(in vec2 vertex, in vec2 texCoord) {
        vertices.insert(vertex);
        texCoords.insert(texCoord);
    }

    void updateVertex(in int index, in vec2 vertex) {
        vertices[index] = vertex;

        const size = GLfloat.sizeof*2;
        const offset = size*index;

        glBindBuffer(GL_ARRAY_BUFFER, verticesId);
        glBufferSubData(GL_ARRAY_BUFFER, offset, size, vertices[index].value_ptr);
    }

    void updateVertices(in vec2[] vertices) {
        this.vertices.clear();
        this.vertices ~= vertices;
        remapVertices();
    }

    void remapVertices() {
        const verticesSize = to!int(GLfloat.sizeof*2*vertices.length);

        glBindBuffer(GL_ARRAY_BUFFER, verticesId);
        glBufferSubData(GL_ARRAY_BUFFER, 0, verticesSize, vertices[0].value_ptr);
    }

    void addIndex(in GLuint index) {
        indices.insert(index);
    }

    void addIndices(in GLuint[] indices) {
        this.indices ~= indices;
    }

    @property size_t indicesLength() {
        return indices.length;
    }

    @property size_t verticesLength() {
        return vertices.length;
    }

    void updateIndices(in GLuint[] indices) {
        this.indices.clear();
        this.indices ~= indices;
    }

    void linearFillIndices() {
        for (int i = 0; i < vertices.length; ++i) {
            addIndex(i);
        }
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

    bool dynamic;
    GLuint renderMode;

    void createVBO() {
        // Vertex buffer
        glGenBuffers(1, &verticesId);
        glBindBuffer(GL_ARRAY_BUFFER, verticesId);

        const int verticesSize = to!int(GLfloat.sizeof*2*vertices.length);

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

        const int texCoordsSize = to!int(GLfloat.sizeof*2*texCoords.length);
        glBufferData (GL_ARRAY_BUFFER, texCoordsSize, &texCoords[0], GL_STATIC_DRAW);

        // Indices buffer
        glGenBuffers(1, &indicesId);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indicesId);

        const int indicesSize = to!int(GLuint.sizeof*indices.length);
        glBufferData (GL_ELEMENT_ARRAY_BUFFER, indicesSize, &indices[0], GL_STATIC_DRAW);

        //auto settings = Settings.getInstance();

        if (settings.VAOEXT) {
            if (settings.OGLMajor >= 3) createVAO_33();
            else createVAO_21();
        }
    }

    // Binding buffers without VAO
    void bindBuffers() {
        // Texture coordinates
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
        glBindBuffer(GL_ARRAY_BUFFER, texCoordsId);
        glTexCoordPointer(2, GL_FLOAT, 0, null);

        // Vertices
        const int verticesSize = to!int(GLfloat.sizeof*2*vertices.length);
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

        const int verticesSize = to!int(GLfloat.sizeof*2*vertices.length);
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

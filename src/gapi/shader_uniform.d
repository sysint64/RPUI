module gapi.shader_uniform;


mixin template ShaderUniform() {
    void setUniformFloat(in string location, in float val) {
        chechOrCreateLocation(location);
        glUniform1f(locations[location], val);
    }

    void setUniformInt(in string location, in int val) {
        chechOrCreateLocation(location);
        glUniform1i(locations[location], val);
    }

    void setUniformUInt(in string location, in uint val) {
        chechOrCreateLocation(location);
        glUniform1ui(locations[location], val);
    }

    void setUniformTexture(in string location, Texture texture) {
        glActiveTexture(GL_TEXTURE0 + nextTextureID);
        texture.bind();

        chechOrCreateLocation(location);
        glUniform1i(locations[location], nextTextureID);

        ++nextTextureID;
    }

    // Float Vector

    void setUniformVec2f(in string location, in vec2 vector) {
        chechOrCreateLocation(location);
        glUniform2fv(locations[location], 1, vector.value_ptr);
    }

    void setUniformVec2f(in string location, in float x, float y) {
        chechOrCreateLocation(location);
        glUniform2f(locations[location], x, y);
    }

    void setUniformVec3f(in string location, in vec3 vector) {
        chechOrCreateLocation(location);
        glUniform3fv(locations[location], 1, vector.value_ptr);
    }

    void setUniformVec3f(in string location, in float x, in float y, in float z) {
        chechOrCreateLocation(location);
        glUniform3f(locations[location], x, y, z);
    }

    void setUniformVec4f(in string location, in vec4 vector) {
        chechOrCreateLocation(location);
        glUniform4fv(locations[location], 1, vector.value_ptr);
    }

    void setUniformVec4f(in string location, in float x, in float y, in float z, in float w) {
        chechOrCreateLocation(location);
        glUniform4f(locations[location], x, y, z, w);
    }

    // Integer Vector

    void setUniformVec2i(in string location, in vec2i vector) {
        chechOrCreateLocation(location);
        glUniform2iv(locations[location], 1, vector.value_ptr);
    }

    void setUniformVec2i(in string location, in int x, in int y) {
        chechOrCreateLocation(location);
        glUniform2i(locations[location], x, y);
    }

    void setUniformVec3i(in string location, in vec3i vector) {
        chechOrCreateLocation(location);
        glUniform3iv(locations[location], 1, vector.value_ptr);
    }

    void setUniformVec3i(in string location, in int x, in int y, in int z) {
        chechOrCreateLocation(location);
        glUniform3i(locations[location], x, y, z);
    }

    void setUniformVec4i(in string location, in vec4i vector) {
        chechOrCreateLocation(location);
        glUniform4iv(locations[location], 1, vector.value_ptr);
    }

    void setUniformVec4i(in string location, in int x,in int y,in int z,in int w) {
        chechOrCreateLocation(location);
        glUniform4i(locations[location], x, y, z, w);
    }

    // Unsigned int

    void setUniformVec2ui(in string location, in vec2ui vector) {
        chechOrCreateLocation(location);
        glUniform2uiv(locations[location], 1, vector.value_ptr);
    }

    void setUniformVec2ui(in string location, in int x, in int y) {
        chechOrCreateLocation(location);
        glUniform2ui(locations[location], x, y);
    }

    void setUniformVec3ui(in string location, in vec3ui vector) {
        chechOrCreateLocation(location);
        glUniform3uiv(locations[location], 1, vector.value_ptr);
    }

    void setUniformVec3ui(in string location, in uint x, in uint y, in uint z) {
        chechOrCreateLocation(location);
        glUniform3ui(locations[location], x, y, z);
    }

    void setUniformVec4ui(in string location, in vec4ui vector) {
        chechOrCreateLocation(location);
        glUniform4uiv(locations[location], 1, vector.value_ptr);
    }

    void setUniformVec4ui(in string location, in uint x,in uint y,in uint z,in uint w) {
        chechOrCreateLocation(location);
        glUniform4ui(locations[location], x, y, z, w);
    }

    // Matrix

    void setUniformMatrix(in string location, in mat4 matrix) {
        chechOrCreateLocation(location);
        glUniformMatrix4fv(locations[location], 1, GL_TRUE, matrix.value_ptr);
    }

    void setUniformMatrix2(in string location, in mat2 matrix) {
        chechOrCreateLocation(location);
        glUniformMatrix2fv(locations[location], 1, GL_TRUE, matrix.value_ptr);
    }

    void setUniformMatrix3(in string location, in mat3 matrix) {
        chechOrCreateLocation(location);
        glUniformMatrix3fv(locations[location], 1, GL_TRUE, matrix.value_ptr);
    }

    void setUniformMatrix4(in string location, in mat4 matrix) {
        chechOrCreateLocation(location);
        glUniformMatrix4fv(locations[location], 1, GL_TRUE, matrix.value_ptr);
    }

    void setUniformMatrix2x3(in string location, in mat23 matrix) {
        chechOrCreateLocation(location);
        glUniformMatrix2x3fv(locations[location], 1, GL_TRUE, matrix.value_ptr);
    }

    void setUniformMatrix3x2(in string location, in mat32 matrix) {
        chechOrCreateLocation(location);
        glUniformMatrix3x2fv(locations[location], 1, GL_TRUE, matrix.value_ptr);
    }

    void setUniformMatrix2x4(in string location, in mat24 matrix) {
        chechOrCreateLocation(location);
        glUniformMatrix2x4fv(locations[location], 1, GL_TRUE, matrix.value_ptr);
    }

    void setUniformMatrix4x2(in string location, in mat42 matrix) {
        chechOrCreateLocation(location);
        glUniformMatrix4x2fv(locations[location], 1, GL_TRUE, matrix.value_ptr);
    }

    void setUniformMatrix3x4(in string location, in mat34 matrix) {
        chechOrCreateLocation(location);
        glUniformMatrix3x4fv(locations[location], 1, GL_TRUE, matrix.value_ptr);
    }

    void setUniformMatrix4x3(in string location, in mat43 matrix) {
        chechOrCreateLocation(location);
        glUniformMatrix4x3fv(locations[location], 1, GL_TRUE, matrix.value_ptr);
    }
}

module gapi.shader;

import std.file;
import std.stdio;
import std.string;

import gapi.shader_uniform;
import gapi.texture;

import derelict.opengl3.gl;
import math.linalg;


class Shader {
    mixin ShaderUniform;

    void load(in string fileName) {
        this.file = File(fileName, "r");

        while (!file.eof) {
            char ch = readChar();

            if (file.eof)
                break;

            if (ch == '#')
                parseHeader();
            else
                shaderSources[currentSource] ~= ch;
        }

        writeln("FRAGMENT SHADER");
        writeln(shaderSources[ShaderSource.fragment]);

        writeln("VERTEX SHADER");
        writeln(shaderSources[ShaderSource.vertex]);

        createShaders();
    }

    void bind() {
        nextTextureID = 1;
        glUseProgram(program);
    }

    void unbind() {
        glUseProgram(0);
    }

    this(in string fileName) {
        load(fileName);
    }

private:
    File file;
    enum ShaderSource {fragment, vertex};
    string[ShaderSource.max + 1] shaderSources;
    ShaderSource currentSource = ShaderSource.fragment;
    GLuint program;
    GLuint[string] locations;
    uint nextTextureID = 1;

    void chechOrCreateLocation(in string location) {
        if ((location in locations) is null) {
            const char* name_cstr = toStringz(location);
            locations[location] = glGetUniformLocation(program, name_cstr);
        }
    }

    char readChar() {
        auto buf = file.rawRead(new char[1]);

        if (file.eof) return char.init;
        else return buf[0];
    }

    void parseHeader() {
        char ch = readChar();
        string header = "";

        while (ch != '\r' && ch != '\n') {
            header ~= ch;
            ch = readChar();
        }

        switch (header) {
            case "vertex shader":
                currentSource = ShaderSource.vertex;
                break;

            case "fragment shader":
                currentSource = ShaderSource.fragment;
                break;

            default:
                shaderSources[currentSource] ~= "#" ~ header;
        }
    }

    GLint checkStatus(string statusInfo)(ref GLuint shader, GLenum param) {
        GLint status, length;
	GLchar[1024] buffer;

        mixin("glGet" ~ statusInfo ~ "iv(shader, param, &status);");

        if (status != GL_TRUE) {
            mixin("glGet" ~ statusInfo ~ "InfoLog(shader, 1024, &length, &buffer[0]);");
            writeln(status, "error(", ")", buffer);
        }

        return status;
    }

    GLint shaderStatus(ref GLuint shader, GLenum param) {
        return checkStatus!("Shader")(shader, param);
    }

    GLint programStatus(ref GLuint shader, GLenum param) {
        return checkStatus!("Program")(shader, param);
    }

    void createShaders() {
        // Create Vertex Shader
        const char* vertexSource = toStringz(shaderSources[ShaderSource.vertex]);
        GLuint vertexShader = glCreateShader(GL_VERTEX_SHADER);
        glShaderSource(vertexShader, 1, &vertexSource, null);
        glCompileShader(vertexShader);

        writeln("Vertex Shader");
        shaderStatus(vertexShader, GL_COMPILE_STATUS);

        // Create Fragment Shader
        const char* fragmentSource = toStringz(shaderSources[ShaderSource.fragment]);
        GLuint fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
        glShaderSource(fragmentShader, 1, &fragmentSource, null);
        glCompileShader(fragmentShader);

        writeln("Fragment Shader");
        shaderStatus(fragmentShader, GL_COMPILE_STATUS);

        // Link Shaders
        program = glCreateProgram();

        glAttachShader(program, vertexShader);
        glAttachShader(program, fragmentShader);

        glValidateProgram(program);
        glLinkProgram(program);
        // programStatus(program, GL_LINK_STATUS);
    }
}

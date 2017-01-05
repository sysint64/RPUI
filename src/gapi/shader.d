module gapi.shader;

import std.file;
import std.stdio;
import std.string;

import derelict.opengl3.gl3;


class Shader {
    void load(in string fileName) {
        this.file = File(fileName, "r");

        while (!file.eof) {
            char ch = readChar();

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

    void createShaders() {
        // Create Vertex Shader
        const char* vertexSource = toStringz(shaderSources[ShaderSource.vertex]);
        GLuint vertexShader = glCreateShader(GL_VERTEX_SHADER);
        glShaderSource(vertexShader, 1, &vertexSource, null);
        glCompileShader(vertexShader);

        // Create Fragment Shader
        const char* fragmentSource = toStringz(shaderSources[ShaderSource.fragment]);
        GLuint fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
        glShaderSource(fragmentShader, 1, &fragmentSource, null);
        glCompileShader(fragmentShader);

        // Link Shaders
        program = glCreateProgram();
        glAttachShader(program, vertexShader);
        glAttachShader(program, fragmentShader);
        glLinkProgram(program);
    }
}

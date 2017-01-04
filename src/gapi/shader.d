module gapi.shader;

import std.file;
import std.stdio;


class Shader {
    void load(in string fileName) {
        this.file = File(fileName, "r");

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
        }
    }

private:
    File file;
    string fragmentShaderSource;
    string vertexShaderSource;
}

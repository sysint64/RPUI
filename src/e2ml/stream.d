module e2ml.stream;

import std.stdio;
import std.file;
import core.stdc.stdio;


class SymbolStream {
public:
    char read() {
        readChar();

        if (p_lastChar == ' ' && tabSize == 0 && needCalcTabSize && needCalcIndent)
            return calcTabSize();

        if (p_lastChar == ' ' && tabSize > 0 && needCalcIndent)
            return calcIndent();

        if (p_lastChar == '\r' || p_lastChar == '\n') {
            needCalcIndent = true;

            p_indent = 0;
            ++p_line;

            return p_lastChar;
        }

        needCalcIndent = false;
        return p_lastChar;
    }

    this(in string fileName) {
        assert(fileName.isFile);
        this.file = File(fileName);
    }

    ~this() {
        file.close();
    }

    @property int line() { return p_line; }
    @property int pos() { return p_pos; }
    @property int indent() { return p_indent; }
    @property int tabSize() { return p_tabSize; }
    @property bool eof() { return file.eof; }
    @property char lastChar() { return p_lastChar; }

private:
    File file;

    int  p_line, p_pos;
    char p_lastChar;
    int  p_indent = 0;
    int  p_tabSize = 0;

    bool needCalcTabSize = true;
    bool needCalcIndent  = true;

    char readChar() {
        auto buf = file.rawRead(new char[1]);
        ++p_pos;

        if (file.eof) p_lastChar = char.init;
        else p_lastChar = buf[0];

        return p_lastChar;
    }

    char calcIndent() {
        uint spaces = 0;

        while (p_lastChar == ' ') {
            ++spaces;
            readChar();

            if (spaces == p_tabSize) {
                ++p_indent;
                spaces = 0;
            }
        }

        return p_lastChar;
    }

    char calcTabSize() {
        while (p_lastChar == ' ') {
            ++p_tabSize;
            readChar();
        }

        ++p_indent;
        needCalcTabSize = false;

        return p_lastChar;
    }
}

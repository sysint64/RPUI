module e2ml.stream;

import std.stdio;
import std.file;
import core.stdc.stdio;


class SymbolStream {
public:
    char read() {
        lastChar = file.rawRead(new char[1])[0];
        return lastChar;
    }

    this(in string fileName) {
        assert(fileName.isFile);
        this.file = File(fileName);
    }

    @property int line() { return p_line; }
    @property int pos() { return p_pos; }
    @property bool eof() { return file.eof; }
    @property char lastChar() { return p_lastChar; }

private:
    File file;
    int p_line, p_pos;
    char p_lastChar;

    @property void lastChar(char val) { p_lastChar = val; }
}

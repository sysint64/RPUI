module e2ml.lexer;

import std.stdio;
import std.format : formattedWrite;
import std.array : appender;

import e2ml.token;
import e2ml.stream;


class LexerError : Exception {
    this(in uint line, in uint pos, in string details) {
        auto writer = appender!string();
        formattedWrite(writer, "line %d, pos %d: %s", line, pos, details);
        super(writer.data);
    }
}


class Lexer {
private:
    SymbolStream stream;
    int p_tabSize;
    Token p_currentToken;

    @property void tabSize(in int tabSize) { p_tabSize = tabSize; }

    Token lexToken() {
        switch (stream.lastChar) {
            case ' ', '\n', '\r':
                stream.read();
                break;

            case '0': .. case '9': case '-', '+':
                return new NumberToken(stream);

            case 'A': .. case 'Z': case 'a': .. case 'z': case '_':
                return new IdToken(stream);

            case '\"':
                return new StringToken(stream);

            case '#':
                skipComment(); break;

            default:
                throw new LexerError(1, 1, "Unknown character");
        }

        return null;
    }

    void skipComment() {
        while (!stream.eof && stream.lastChar != '\n' && stream.lastChar != '\r')
            stream.read();
    }

public:
    @property int tabSize() { return this.p_tabSize; }
    @property Token currentToken() { return this.p_currentToken; }

    this(ref SymbolStream stream) {
        this.stream = stream;
    }

//    Token lexNextToken();
//    Token lexPrevToken();
}

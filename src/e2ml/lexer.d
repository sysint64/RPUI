module e2ml.lexer;

import std.stdio;
import std.format : formattedWrite;
import std.array : appender;
import std.ascii;

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
    bool negative = false;

    int p_tabSize;
    Token p_currentToken;

    Token lexToken() {
        stream.read();

        switch (stream.lastChar) {
            case ' ', '\n', '\r':
                stream.read();
                break;

            case '-', '+':
                negative = stream.lastChar == '-';
                stream.read();

                if (!isDigit(stream.lastChar)) {
                    negative = false;
                    goto default;
                }

            case '0': .. case '9':
                return new NumberToken(stream, negative);

            case 'A': .. case 'Z': case 'a': .. case 'z': case '_':
                return new IdToken(stream);

            case '\"':
                return new StringToken(stream);

            case '#':
                skipComment();
                return lexToken();

            default:
                auto message = "unknown character " ~ stream.lastChar;
                throw new LexerError(stream.line, stream.pos, message);
        }

        return null;
    }

    void skipComment() {
        while (!stream.eof && stream.lastChar != '\n' && stream.lastChar != '\r')
            stream.read();
    }

public:
    this(ref SymbolStream stream) {
        this.stream = stream;
    }

    Token getNextToken() {
        return lexToken();
    }
//    Token lexPrevToken();
}

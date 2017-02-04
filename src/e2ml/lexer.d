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
    this(SymbolStream stream) {
        this.stream = stream;
        stream.read();
    }

    Token nextToken() {
        if (stackCursor < tokenStack.length) {
            p_currentToken = tokenStack[stackCursor++];
        } else {
            p_currentToken = lexToken();
            tokenStack ~= p_currentToken;
            stackCursor = tokenStack.length;
        }

        return p_currentToken;
    }

    Token prevToken() {
        --stackCursor;
        p_currentToken = tokenStack[stackCursor-1];
        return p_currentToken;
    }

    @property Token currentToken() { return p_currentToken; }

private:
    SymbolStream stream;
    bool negative = false;
    Token p_currentToken;

    Token[] tokenStack;
    size_t stackCursor = 0;

    Token lexToken() {
        switch (stream.lastChar) {
            case ' ', '\n', '\r':
                stream.read();
                return lexToken();

            case '-', '+':
                negative = stream.lastChar == '-';
                stream.read();

                if (!isDigit(stream.lastChar)) {
                    negative = false;
                    goto default;
                }

            case '0': .. case '9':
                auto token = new NumberToken(stream, negative);
                negative = false;
                return token;

            case 'A': .. case 'Z': case 'a': .. case 'z': case '_':
                return new IdToken(stream);

            case '\"':
                return new StringToken(stream);

            case '#':
                skipComment();
                return lexToken();

            default:
                auto token = new SymbolToken(stream, stream.lastChar);
                stream.read();
                return token;
        }
    }

    void skipComment() {
        while (!stream.eof && stream.lastChar != '\n' && stream.lastChar != '\r')
            stream.read();
    }
}

module e2ml.token;

import e2ml.stream;
import e2ml.lexer : LexerError;


enum TokenCode {eof, id, number, string, boolean, include};
class Token {
public:
    this(ref SymbolStream stream) {
        this.stream = stream;
    }

protected:
    SymbolStream stream;
    int indent;
    char symbol;
    TokenCode code;
    string identifier;
    string stringVal;
    bool boolean;
    float number;
}


class CharToken : Token {
    this(ref SymbolStream stream, in char symbol) {
        super(stream);
        this.symbol = symbol;
    }
}


class StringToken : Token {
    this(ref SymbolStream stream) {
        super(stream);
        this.lex();
    }
    @property auto ref value() { return m_value; }

private:
    string m_value;
    @property void value(ref string value) { m_value = value; }

    void lexEscape() {
        stream.read();

        switch (stream.lastChar) {
            case 'n' : value ~= "\n"; break;
            case 'r' : value ~= "\r"; break;
            case '\\': value ~= "\\"; break;
            case '\"': value ~= "\""; break;
            default: break;
        }

        stream.read();
    }

    void lex() {
        ubyte state = 0;

        do {
            stream.read();

            if (stream.lastChar == '\\')
                lexEscape();

            if (stream.lastChar != '\"')
                value ~= stream.lastChar;
        } while (stream.lastChar != '\"' && !stream.eof);

        if (stream.eof)
            throw new LexerError(stream.line, stream.pos, "unexpected end of file");
        else stream.read();
    }
}


class NumberToken : Token {
    this(ref SymbolStream stream) {
        super(stream);
    }

private:
    void lex() {

    }
}


// Identifier: [a-zA-Z_][a-zA-Z0-9_]*
class IdToken : Token {
    this(ref SymbolStream stream) {
        super(stream);
        lex();
    }

private:
    void lex() {
    }
}

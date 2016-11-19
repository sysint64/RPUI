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

private:
    void lex() {
        string value;
        ubyte state = 0;

        do {

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


class IdToken : Token {
    this(ref SymbolStream stream) {
        super(stream);
    }
}


module e2ml.token;

import std.ascii;
import std.uni : toLower;
import std.algorithm.iteration : map;
import std.conv;

import e2ml.stream;
import e2ml.lexer : LexerError;


enum TokenCode {none, id, number, string, boolean, include};
class Token {
public:
    this(ref SymbolStream stream) {
        this.stream = stream;
        this.p_indent = stream.indent;
        this.p_line = stream.line;
        this.p_pos = stream.pos;
    }

    @property const string identifier() { return p_identifier; }
    @property const float number() { return p_number; }
    @property const bool boolean() { return p_boolean; }
    @property const string str() { return p_string; }
    @property const string urfStr() { return p_string; }
    @property const TokenCode code() { return p_code; }
    @property const int indent() { return p_indent; }
    @property const char symbol() { return p_symbol; }
    @property const int line() { return p_line; }
    @property const int pos() { return p_pos; }

protected:
    SymbolStream stream;
    char p_symbol;

    // values
    string p_identifier;
    float p_number;
    bool p_boolean;
    string p_string;
    TokenCode p_code;
    int p_indent;
    int p_line;
    int p_pos;
}


class SymbolToken : Token {
    this(ref SymbolStream stream, in char symbol) {
        super(stream);
        this.p_symbol = symbol;
    }
}


class StringToken : Token {
    this(ref SymbolStream stream) {
        super(stream);
        this.lex();
    }

private:
    void lexEscape() {
        stream.read();

        switch (stream.lastChar) {
            case 'n' : p_string ~= "\n"; break;
            case 'r' : p_string ~= "\r"; break;
            case '\\': p_string ~= "\\"; break;
            case '\"': p_string ~= "\""; break;
            default:
                auto message = "undefined escape sequence \\" ~ stream.lastChar;
                throw new LexerError(stream.line, stream.pos, message);
        }

        stream.read();
    }

    void lex() {
        do {
            stream.read();

            if (stream.lastChar == '\\')
                lexEscape();

            if (stream.lastChar != '\"')
                p_string ~= stream.lastChar;
        } while (stream.lastChar != '\"' && !stream.eof);

        if (stream.eof)
            throw new LexerError(stream.line, stream.pos, "unexpected end of file");
        else stream.read();

        p_code = TokenCode.string;
    }
}


// Number Float or Integer: [0-9]+ (.[0-9]+)?
class NumberToken : Token {
    this(ref SymbolStream stream, in bool negative = false) {
        super(stream);
        this.negative = negative;
        lex();
    }

private:
    bool negative = false;

    bool isNumberChar() {
        return isDigit(stream.lastChar) || stream.lastChar == '.';
    }

    void lex() {
        string numStr = negative ? "-" : "";
        p_code = TokenCode.number;
        bool hasComma = false;

        while (isNumberChar()) {
            if (stream.lastChar == '.') {
                if (hasComma)
                    break;

                hasComma = true;
            }

            numStr ~= stream.lastChar;
            stream.read();
        }

        p_number = to!float(numStr);
    }
}


// Identifier: [a-zA-Z_][a-zA-Z0-9_]*
class IdToken : Token {
    this(ref SymbolStream stream) {
        super(stream);
        p_code = TokenCode.id;
        lex();
    }

private:
    bool isIdChar() {
        return isAlphaNum(stream.lastChar) || stream.lastChar == '_';
    }

    void lex() {
        uint lastIndent;

        while (isIdChar()) {
            p_identifier ~= stream.lastChar;
            lastIndent = stream.indent;
            stream.read();
        }

        p_identifier = p_identifier.toLower();

        switch (identifier) {
            case "include":
                p_code = TokenCode.include;
                return;

            case "true":
                p_code = TokenCode.boolean;
                p_boolean = true;
                return;

            case "false":
                p_code = TokenCode.boolean;
                p_boolean = false;
                return;

            default:
                p_code = TokenCode.id;
        }
    }
}

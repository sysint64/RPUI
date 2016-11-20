module e2ml.parser;

import std.stdio;
import std.format : formattedWrite;
import std.array : appender;

import e2ml.lexer;
import e2ml.token;
import e2ml.stream;
import e2ml.node;


class ParseError : Exception {
    this(in uint line, in uint pos, in string details) {
        auto writer = appender!string();
        formattedWrite(writer, "line %d, pos %d: %s", line, pos, details);
        super(writer.data);
    }
}


class Parser {
    this(ref Lexer lexer, ref SymbolStream stream) {
        this.lexer  = lexer;
        this.stream = stream;
    }

    void parse() {
        lexer.nextToken();

        switch (lexer.currentToken.code) {
            case TokenCode.id: parseObject(); break;
            default:
                throw new ParseError(line, pos, ":(");
        }
    }

private:
    Lexer lexer;
    SymbolStream stream;

    @property int indent() { return lexer.currentToken.indent; }
    @property int line()   { return lexer.currentToken.line;   }
    @property int pos()    { return lexer.currentToken.pos;    }

    void parseObject() {
        string name = lexer.currentToken.identifier;
        string type = "";
        Parameter[] parameters;

        auto node = new Node(name);
        int objectIndent = indent;
        lexer.nextToken();

        if (lexer.currentToken.symbol == '(') {
            lexer.nextToken();

            if (lexer.currentToken.code != TokenCode.id)
                throw new ParseError(line, pos, "expected identifier");

            type = lexer.currentToken.identifier;
            lexer.nextToken();

            if (lexer.currentToken.symbol != ')')
                throw new ParseError(line, pos, "expected ')'");

            lexer.nextToken();
        }

        writeln(name ~ "(" ~ type ~ ")");
        parseParameters(objectIndent);
    }

    void parseParameters(in int objectIndent) {
        Token objectToken = lexer.currentToken;

        while (true) {
            string paramName = lexer.currentToken.identifier;
            int targetIndent = indent-1;

            lexer.nextToken();

            if (objectIndent != targetIndent && lexer.currentToken.line != objectToken.line) {
                writeln("EXIT");
                break;
            }

            const auto code   = lexer.currentToken.code;
            const auto symbol = lexer.currentToken.symbol;

            if (code != TokenCode.id && symbol != ':' && symbol != '(')
                break;

            if (lexer.currentToken.symbol != ':') {
                lexer.prevToken();
                parseObject();
                continue;
            }

            parseParameter(paramName);
        }

        lexer.prevToken();
    }

    void parseParameter(in string name) {
        writeln(name);

        while (true) {
            parseValue("0");
            lexer.nextToken();

            if (lexer.currentToken.symbol != ',')
                break;
        }
    }

    void parseValue(in string name) {
        lexer.nextToken();

        if (lexer.currentToken.symbol == '[') {
            parseArray(name);
            return;
        }

        switch (lexer.currentToken.code) {
            case TokenCode.number:
                return;

            case TokenCode.string:
                return;

            case TokenCode.id:
                return;

            case TokenCode.boolean:
                return;

            default:
                throw new ParseError(line, pos, "value error");
        }
    }

    void parseArray(in string name) {
        const auto code = lexer.currentToken.code;
        while (code != ']' || code != TokenCode.none) {
            parseValue("0");
            lexer.nextToken();

            const auto symbol = lexer.currentToken.symbol;

            if (symbol != ',' && symbol != ']')
                throw new ParseError(line, pos, "expected ',' or ']'");

            if (symbol == ']')
                break;
        }
    }

    void parseInclude() {

    }
}

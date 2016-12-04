module e2ml.parser;

import std.stdio;
import std.format : formattedWrite;
import std.array : appender;
import std.conv;

import e2ml.lexer;
import e2ml.token;
import e2ml.stream;
import e2ml.node;
import e2ml.value;


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
            case TokenCode.id: parseObject(root); break;
            default:
                throw new ParseError(line, pos, ":(");
        }
    }

    Node  root = new Node("");

private:
    Lexer lexer;
    SymbolStream stream;

    @property int indent() { return lexer.currentToken.indent; }
    @property int line()   { return lexer.currentToken.line;   }
    @property int pos()    { return lexer.currentToken.pos;    }

    Node parseObject(ref Node parent) {
        string name = lexer.currentToken.identifier;
        string type = "";
        Parameter[] parameters;

        auto node = new Node(name, parent);

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
        parseParameters(objectIndent, node);

        return node;
    }

    Parameter[] parseParameters(in int objectIndent, ref Node node) {
        assert(node !is null);

        Token objectToken = lexer.currentToken;
        Parameter[] parameters;
        int counter = 0;

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
                parseObject(node);
                continue;
            }

            counter++;
            parameters ~= parseParameter(paramName);
        }

        lexer.prevToken();
        return parameters;
    }

    Parameter parseParameter(in string name) {
        writeln(name);
        Value[] values;

        while (true) {
            string valueName = to!string(values.length);
            values ~= parseValue(valueName);
            lexer.nextToken();

            if (lexer.currentToken.symbol != ',')
                break;
        }

        return new Parameter();
    }

    Value parseValue(in string name) {
        lexer.nextToken();

        if (lexer.currentToken.symbol == '[')
            return parseArray(name);

        switch (lexer.currentToken.code) {
            case TokenCode.number:
                return null;

            case TokenCode.string:
                return null;

            case TokenCode.id:
                return null;

            case TokenCode.boolean:
                return null;

            default:
                throw new ParseError(line, pos, "value error");
        }
    }

    Value parseArray(in string name) {
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

        return null;
    }

    void parseInclude() {

    }
}

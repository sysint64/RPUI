module e2ml.parser;

import std.stdio;
import std.format : formattedWrite;
import std.array : appender;

import e2ml.lexer;


class ParseError : Exception {
    this(in uint line, in uint pos, in string details) {
        auto writer = appender!string();
        formattedWrite(writer, "line %d, pos %d: %s", line, pos, details);
        super(writer.data);
    }
}


class Parser {
private:
    Lexer lexer;

public:
    this(ref Lexer lexer) {
        this.lexer = lexer;
    }

    void parse() {

    }
}

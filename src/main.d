module main;

import std.stdio;

import e2ml.data;
import e2ml.stream;
import e2ml.lexer;
import e2ml.token;


void main() {
    Data data = new Data();
    data.load("/home/dev/dev/e2dit/e2tml/tests/simple.e2t");
    writeln(":)");

    SymbolStream stream = new SymbolStream("/home/dev/dev/e2dit-dlang/tests/simple.e2t");
    Lexer lexer = new Lexer(stream);

    Token token = lexer.getNextToken();
    writeln((cast(StringToken)token).str);

    Token token2 = lexer.getNextToken();
    writeln((cast(IdToken)token2).identifier);
}

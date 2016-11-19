module main;

import std.stdio;

import e2ml.data;
import e2ml.stream;
import e2ml.lexer;
import e2ml.token;


void main() {
//    Data data = new Data();
//    data.load("/home/dev/dev/e2dit/e2tml/tests/simple.e2t");
//    writeln(":)");

    SymbolStream stream = new SymbolStream("/home/dev/dev/e2dit-dlang/tests/simple.e2t");
    Lexer lexer = new Lexer(stream);

    Token token1 = lexer.getNextToken();
    writeln(token1.identifier);

    Token token2 = lexer.getNextToken();
    writeln(token2.identifier);
    writeln(stream.indent);
    writeln(stream.tabSize);

    Token token3 = lexer.getNextToken();
    writeln(token3.identifier);
    writeln(token3.symbol);
    writeln(stream.indent);
    writeln(stream.tabSize);

    Token token4 = lexer.getNextToken();
    writeln(token4.identifier);
    writeln(token4.number);
    writeln(stream.indent);
    writeln(stream.tabSize);
}

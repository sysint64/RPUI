module e2ml.data;

import std.file;
import std.stdio;

import e2ml.lexer;
import e2ml.parser;
import e2ml.stream;


class Data {
private:
    Lexer lexer;
    Parser parser;

public:
    enum IOType {text, bin};

    void load(in string fileName, in IOType rt = IOType.text) {
        SymbolStream stream = new SymbolStream(fileName);

        this.lexer  = new Lexer(stream);
        this.parser = new Parser(lexer);

        this.parser.parse();
    }
}

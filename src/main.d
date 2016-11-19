module main;
import std.stdio;
import e2ml.data;


void main() {
    Data data = new Data();
    data.load("/home/dev/dev/e2dit/e2tml/tests/simple.e2t");
    writeln(":)");

    File file = File("/home/dev/dev/e2dit/e2tml/tests/simple.e2t");
    auto a = file.rawRead(new char[1]);
    writeln(a[0]);
}

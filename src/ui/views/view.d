module ui.views.view;

import std.traits;
import std.stdio;

import ui.views.attributes;
import ui.manager;


class View {
    this(this T)(Manager manager) {
        assert(manager !is null);

        foreach (symbol; getSymbolsByUDA!(T, OnClickListener)) {
            assert(isFunction!symbol);

            foreach (uda; getUDAs!(symbol, OnClickListener)) {
                writeln(uda.id);
                // uda.id
            }
        }
    }

    static createFromFile(T : View)(Manager manager, in string fileName) {
        T view = new T(manager);



        return view;
    }
}

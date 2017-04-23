module ui.views.view;

import std.traits : hasUDA, getUDAs, isFunction;
import std.stdio;
import std.path;

import application;
import rpdl;
import ui.views.attributes;
import ui.manager;


// TODO: rm, workaround
template getSymbolsByUDA(alias symbol, alias attribute) {
    import std.format : format;
    import std.meta : AliasSeq, Filter;

    // translate a list of strings into symbols. mixing in the entire alias
    // avoids trying to access the symbol, which could cause a privacy violation
    template toSymbols(names...) {
        static if (names.length == 0)
            alias toSymbols = AliasSeq!();
        else
            mixin("alias toSymbols = AliasSeq!(symbol.%s, toSymbols!(names[1..$]));"
                  .format(names[0]));
    }

    // filtering not compiled members such as inaccessible members
    enum noInaccessibleMembers(string name) = (__traits(compiles, __traits(getMember, symbol, name)));
    alias withoutInaccessibleMembers = Filter!(noInaccessibleMembers, __traits(allMembers, symbol));

    // filtering out nested class context
    enum noThisMember(string name) = (name != "this");
    alias membersWithoutNestedCC = Filter!(noThisMember, withoutInaccessibleMembers);

    enum hasSpecificUDA(string name) = mixin("hasUDA!(symbol.%s, attribute)".format(name));
    alias membersWithUDA = toSymbols!(Filter!(hasSpecificUDA, membersWithoutNestedCC));

    // if the symbol itself has the UDA, tack it on to the front of the list
    static if (hasUDA!(symbol, attribute))
        alias getSymbolsByUDA = AliasSeq!(symbol, membersWithUDA);
    else
        alias getSymbolsByUDA = membersWithUDA;
}


class View {
    Application app;

    this(this T)(Manager manager, in string fileName) {
        assert(manager !is null);
        app = Application.getInstance();

        foreach (symbol; getSymbolsByUDA!(T, OnClickListener)) {
            assert(isFunction!symbol);

            foreach (uda; getUDAs!(symbol, OnClickListener)) {
                writeln(uda.id);
                // uda.id
            }
        }

        // layoutData = new RPDLTree(fileName);
        // layoutData.load(fileName);
    }

    static createFromFile(T : View)(Manager manager, in string fileName) {
        auto app = Application.getInstance();
        const string path = buildPath(app.resourcesDirectory, "ui", "layouts", fileName);

        T view = new T(manager, path);

        return view;
    }

private:
    RPDLTree layoutData;
}

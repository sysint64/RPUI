module ui.views.view;

import std.traits : hasUDA, getUDAs, isFunction, isType, isAggregateType;
import std.stdio;
import std.path;

import application;

import ui.widget;
import ui.widgets.rpdl_factory;
import ui.views.attributes;
import ui.manager;
import ui.widgets.panel.widget;


// TODO: rm, workaround
template getSymbolsNamesByUDA(alias symbol, alias attribute) {
    import std.format : format;
    import std.meta : AliasSeq, Filter;

    // filtering inaccessible members
    enum noInaccessibleMembers(string name) = (__traits(compiles, __traits(getMember, symbol, name)));
    alias withoutInaccessibleMembers = Filter!(noInaccessibleMembers, __traits(allMembers, symbol));

    // filtering out nested class context
    enum noThisMember(string name) = (name != "this");
    alias membersWithoutNestedCC = Filter!(noThisMember, withoutInaccessibleMembers);

    // filtering not compiled members such as alias of basic types
    enum noIncorrectMembers(string name) = (__traits(compiles, mixin("hasUDA!(symbol.%s, attribute)".format(name))));
    alias withoutIncorrectMembers = Filter!(noIncorrectMembers, membersWithoutNestedCC);

    enum hasSpecificUDA(string name) = mixin("hasUDA!(symbol.%s, attribute)".format(name));
    alias membersWithUDA = Filter!(hasSpecificUDA, withoutIncorrectMembers);

    // if the symbol itself has the UDA, tack it on to the front of the list
    static if (hasUDA!(symbol, attribute))
        alias getSymbolsNamesByUDA = AliasSeq!(symbol, membersWithUDA);
    else
        alias getSymbolsNamesByUDA = membersWithUDA;
}


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

    alias getSymbolsByUDA = toSymbols!(getSymbolsNamesByUDA!(symbol, attribute));
}


class View {
    Application app;
    Manager uiManager;

    this(this T)(Manager manager, in string fileName) {
        assert(manager !is null);
        app = Application.getInstance();
        this.uiManager = manager;

        foreach (symbol; getSymbolsByUDA!(T, OnClickListener)) {
            assert(isFunction!symbol);

            foreach (uda; getUDAs!(symbol, OnClickListener)) {
                writeln(uda.id);
                // uda.id
            }
        }

        widgetFactory = new RPDLWidgetFactory(fileName);
        widgetFactory.createWidgets(uiManager);
    }

    static createFromFile(T : View)(Manager manager, in string fileName) {
        auto app = Application.getInstance();
        const string path = buildPath(app.resourcesDirectory, "ui", "layouts", fileName);
        return new T(manager, path);
    }

private:
    RPDLWidgetFactory widgetFactory;
}

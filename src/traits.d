module traits;

import std.traits : hasUDA, getUDAs, isFunction, isType, isAggregateType;


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
    enum hasSpecificUDA(string name) = mixin("hasUDA!(symbol." ~ name ~ ", attribute)");
    enum noIncorrectMembers(string name) = (__traits(compiles, hasSpecificUDA!(name)));

    alias withoutIncorrectMembers = Filter!(noIncorrectMembers, membersWithoutNestedCC);
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

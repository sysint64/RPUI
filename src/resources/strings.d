/**
 * Copyright: © 2017 Andrey Kabylin
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 */

module resources.strings;

import std.path;
import std.typecons;
import std.algorithm: canFind;
import std.ascii;
import std.conv;

import basic_types;
import application;
import path;

import rpdl.tree;

/**
 * This class uses RPDL as strings repository, strings needed for
 * internationalization.
 */
final class StringsRes {
    string locale;  /// Strings locale (langauge).

    private this() {}

    static StringsRes createForLanguage(in Pathes pathes, in string locale) {
        StringsRes stringsRes = new StringsRes();
        stringsRes.locale = locale;

        const string path = buildPath(pathes.resources, "strings", locale);
        stringsRes.strings = new RpdlTree(path);

        return stringsRes;
    }

    static StringsRes createFromFile(in Pathes pathes, in string fileName) {
        const string path = buildPath(pathes.resources, "strings", fileName);
        return createFromAbsolutePath(path);
    }

    static StringsRes createFromAbsolutePath(in string path) {
        StringsRes stringsRes = new StringsRes();
        stringsRes.strings = new RpdlTree(dirName(path));
        stringsRes.strings.load(baseName(path));
        return stringsRes;
    }

final:
    void addStrings(in string fileName) {
        strings.load(fileName);
    }

    utf32string parseString(in utf32string source) {
        utf32string result = "";

        for (size_t i = 0; i < source.length; ++i) {
            const utf32char ch = source[i];

            if (ch == '@') {
                auto reference = parseReference(source, i);
                result ~= reference.value;
                i = reference.endPosition;
            } else {
                result ~= ch;
            }
        }

        return result;
    }

private:
    RpdlTree strings;

    auto parseReference(in utf32string source, in size_t position) {
        utf32string reference = "";
        size_t endPosition = position + 1;
        const referenceAlphabet = letters ~ digits ~ ".";

        for (size_t i = position + 1; i < source.length; ++i) {
            const utf32char ch = source[i];

            if (!referenceAlphabet.canFind(ch))
                break;

            reference ~= ch;
            endPosition = i;
        }

        const value = strings.data.optUTF32String(to!string(reference) ~ ".0", reference);
        return tuple!("value", "endPosition")(value, endPosition);
    }
}

version(unittest) {
    import unit_threaded;
}

///
@("Should parse strings with strings resources")
unittest {
    const pathes = initPathes();
    const path = buildPath(pathes.tests, "strings", "en.rdl");
    auto stringsRes = StringsRes.createFromAbsolutePath(path);

    with (stringsRes) {
        const t = parseReference("@TestView.mainPanelCaption Test string", 0);
        t.value.shouldEqual("This is main panel"d);
        t.endPosition.shouldEqual("TestView.mainPanelCaption".length);
        parseString("Hello, @TestView.mainPanelCaption").shouldEqual("Hello, This is main panel"d);
        parseString("Without reference").shouldEqual("Without reference"d);
    }
}

@("Should parse strings with UTF strings resources")
unittest {
    const pathes = initPathes();
    const path = buildPath(pathes.tests, "strings", "ru.rdl");
    auto stringsRes = StringsRes.createFromAbsolutePath(path);

    with (stringsRes) {
        const t = parseReference("@TestView.mainPanelCaption Test string", 0);
        t.value.shouldEqual("Это главная панель"d);
        t.endPosition.shouldEqual("TestView.mainPanelCaption".length);
        parseString("Привет, @TestView.mainPanelCaption").shouldEqual("Привет, Это главная панель"d);
        parseString("Привет, @TestView.mainPanelCaption").length.shouldEqual(26);
    }
}

/**
 * Copyright: © 2017 RedGoosePaws
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 * Authors: Andrey Kabylin
 */

module resources.strings;

import std.path;
import std.typecons;
import std.algorithm: canFind;
import std.ascii;
import std.conv;

import basic_types;
import application;

import rpdl.tree;

/**
 * This class uses RPDL as strings repository, strings needed for
 * internationalization.
 */
final class StringsRes {
    string locale;  /// Strings locale (langauge).

    private this() {}

    ///
    static StringsRes createForLanguage(in string locale) {
        StringsRes stringsRes = new StringsRes();
        stringsRes.locale = locale;

        auto app = Application.getInstance();
        const string path = buildPath(app.resourcesDirectory, "strings", locale);

        stringsRes.strings = new RPDLTree(path);
        return stringsRes;
    }

    ///
    static StringsRes createFromFile(in string fileName) {
        auto app = Application.getInstance();
        const string path = buildPath(app.resourcesDirectory, "strings", fileName);

        return createFromAbsolutePath(path);
    }

    ///
    static StringsRes createFromAbsolutePath(in string path) {
        StringsRes stringsRes = new StringsRes();

        stringsRes.strings = new RPDLTree(dirName(path));
        stringsRes.strings.load(baseName(path));

        return stringsRes;
    }

final:
    ///
    void addStrings(in string fileName) {
        strings.load(fileName);
    }

    ///
    utfstring parseString(in utfstring source) {
        utfstring result = "";

        for (size_t i = 0; i < source.length; ++i) {
            const utfchar ch = source[i];

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
    RPDLTree strings;

    auto parseReference(in utfstring source, in size_t position) {
        utfstring reference = "";
        size_t endPosition = position + 1;
        const referenceAlphabet = letters ~ digits ~ ".";

        for (size_t i = position + 1; i < source.length; ++i) {
            const utfchar ch = source[i];

            if (!referenceAlphabet.canFind(ch))
                break;

            reference ~= ch;
            endPosition = i;
        }

        const value = strings.data.optUTFString(to!string(reference) ~ ".0", reference);
        return tuple!("value", "endPosition")(value, endPosition);
    }
}

///
unittest {
    import test.core;
    import dunit.assertion;

    initApp();

    auto app = Application.getInstance();
    const path = buildPath(app.testsDirectory, "strings", "en.rdl");

    StringsRes stringsRes = StringsRes.createFromAbsolutePath(path);

    with (stringsRes) {
        const t = parseReference("@TestView.mainPanelCaption Test string", 0);
        assertEquals(t.value, "This is main panel"d);
        assertEquals(t.endPosition, "TestView.mainPanelCaption".length);
        assertEquals(parseString("Hello, @TestView.mainPanelCaption"), "Hello, This is main panel"d);
        assertEquals(parseString("Without reference"), "Without reference"d);
    }
}


// Parsing UTF String
unittest {
    import test.core;
    import dunit.assertion;

    initApp();

    auto app = Application.getInstance();
    const path = buildPath(app.testsDirectory, "strings", "ru.rdl");

    StringsRes stringsRes = StringsRes.createFromAbsolutePath(path);

    with (stringsRes) {
        const t = parseReference("@TestView.mainPanelCaption Test string", 0);
        assertEquals(t.value, "Это главная панель"d);
        assertEquals(t.endPosition, "TestView.mainPanelCaption".length);
        assertEquals(parseString("Привет, @TestView.mainPanelCaption"), "Привет, Это главная панель"d);
        assertEquals(parseString("Привет, @TestView.mainPanelCaption").length, 26);
    }
}

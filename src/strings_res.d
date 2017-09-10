module strings_res;

import std.path;
import std.typecons;
import std.algorithm: canFind;
import std.ascii;
import std.conv;

import basic_types;
import application;

import rpdl.tree;


class StringsRes {
    string locale;

    private this() {}

    static StringsRes createForLanguage(in string locale) {
        StringsRes stringsRes = new StringsRes();
        stringsRes.locale = locale;

        auto app = Application.getInstance();
        const string path = buildPath(app.resourcesDirectory, "strings", locale);

        stringsRes.strings = new RPDLTree(dirName(path));
        return stringsRes;
    }

    static StringsRes createFromFile(in string fileName) {
        StringsRes stringsRes = new StringsRes();

        auto app = Application.getInstance();
        const string path = buildPath(app.resourcesDirectory, "strings", fileName);

        return createFromAbsolutePath(path);
    }

    static StringsRes createFromAbsolutePath(in string path) {
        StringsRes stringsRes = new StringsRes();

        stringsRes.strings = new RPDLTree(dirName(path));
        stringsRes.strings.load(baseName(path));

        return stringsRes;
    }

final:
    void addStrings(in string fileName) {
        strings.load(fileName);
    }

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

        const value = strings.getUTFString(to!string(reference) ~ ".0");
        return tuple!("value", "endPosition")(value, endPosition);
    }
}


unittest {
    import test.core;

    initApp();

    auto app = Application.getInstance();
    const path = buildPath(app.testsDirectory, "strings", "en.rdl");

    StringsRes stringsRes = StringsRes.createFromAbsolutePath(path);

    with (stringsRes) {
        auto t = parseReference("@TestView.mainPanelCaption Test string", 0);
        assert(t.value == "This is main panel");
        assert(t.endPosition == "TestView.mainPanelCaption".length);
        assert(parseString("Hello, @TestView.mainPanelCaption") == "Hello, This is main panel");
    }
}


// Parse UTF String
unittest {
    import test.core;

    initApp();

    auto app = Application.getInstance();
    const path = buildPath(app.testsDirectory, "strings", "ru.rdl");

    StringsRes stringsRes = StringsRes.createFromAbsolutePath(path);

    with (stringsRes) {
        auto t = parseReference("@TestView.mainPanelCaption Test string", 0);
        assert(t.value == "Это главная панель");
        assert(t.endPosition == "TestView.mainPanelCaption".length);
        assert(parseString("Привет, @TestView.mainPanelCaption") == "Привет, Это главная панель");
        assert(parseString("Привет, @TestView.mainPanelCaption").length == 26);
    }
}

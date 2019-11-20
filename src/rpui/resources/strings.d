module rpui.resources.strings;

import std.path;
import std.typecons;
import std.algorithm: canFind;
import std.ascii;
import std.conv;

import rpui.primitives;
import rpui.paths;

import rpdl.tree;

/**
 * This class uses RPDL as strings repository, strings needed for
 * internationalization.
 */
final class StringsRes {
    private RpdlTree strings = null;

    this() {
    }

    void setLocale(in string locale) {
        const paths = createPathes();
        const string path = buildPath(paths.resources, "strings", locale);
        this.strings = new RpdlTree(path);
    }

    void addStrings(in string fileName) {
        if (strings is null)
            return;

        strings.load(fileName);
    }

    utf32string parseString(in utf32string source) {
        if (strings is null)
            return source;

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

    private struct Reference {
        dstring value;
        size_t endPosition;
    }

    private Reference parseReference(in utf32string source, in size_t position) {
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
        return Reference(value, endPosition);
    }
}

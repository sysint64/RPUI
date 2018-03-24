module path;

import std.file : thisExePath;
import std.path;

struct Pathes {
    string bin;
    string resources;
    string tests;
}

Pathes initPathes() {
    const binDirectory = dirName(thisExePath());

    return Pathes(
        binDirectory,
        buildPath(binDirectory, "res"),
        buildPath(binDirectory, "tests")
    );
}

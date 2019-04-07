module rpui.paths;

import std.file : thisExePath;
import std.path;

struct Paths {
    string bin;
    string resources;
    string tests;
}

Paths createPathes() {
    const binDirectory = dirName(thisExePath());

    return Paths(
        binDirectory,
        buildPath(binDirectory, "res"),
        buildPath(binDirectory, "tests")
    );
}

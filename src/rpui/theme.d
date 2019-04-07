module rpui.theme;

import std.path;
import std.file;

import rpdl;
import gapi.font;
import gapi.texture;
import rpui.paths;

struct Theme {
    RpdlTree data;
    const Texture2D skin;
    const Font regularFont;
}

Theme createThemeByName(in string theme) {
    const paths = createPathes();
    const dir = buildPath(paths.resources, "ui", "themes", theme);

    auto tree = new RpdlTree(dir);
    tree.load("theme.rdl");

    const skinPath = buildPath(dir, "controls.png");
    const skin = createTexture2DFromFile(skinPath);

    const regularFontFileName = tree.data.getString("General.regularFont.0");
    const font = createFontFromFile(regularFontFileName);

    return Theme(tree, skin, font);
}

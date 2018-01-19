/**
 * Copyright: © 2017 RedGoosePaws
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 * Authors: Andrey Kabylin
 */

module resources.icons;

import std.path;

import application;
import math.linalg;
import gapi.texture;

import resources.images;

import rpdl.tree;

struct Icon {
    string group;
    string name;
    Texture.Coord texCoord;
}

class IconsRes {
    this(ImagesRes imagesRes) {
        assert(imagesRes !is null);
        this.imagesRes = imagesRes;
        this.app = Application.getInstance();
    }

    Texture getTextureForIcons(in string icons) {
        return this.imagesRes.getTextureForUiTheme(buildPath("icons", icons));
        // return null; // TODO: implement
    }

    Icon getIcon(in string group, in string icon) {
        return Icon(); // TODO: implement
    }

    void addIcons(in string group, in string fileName) {
        const path = buildPath(app.resourcesDirectory, "ui", "icons");
        iconsData[group] = new RPDLTree(path);
        iconsData[group].load(fileName);
    }

private:
    Application app;
    ImagesRes imagesRes;
    RPDLTree[string] iconsData;
}

unittest {
    import test.core;
    import dunit.assertion;

    initApp();

    auto imagesRes = new ImagesRes("light");
    auto iconsRes = new IconsRes(imagesRes);

    iconsRes.addIcons("icons", "icons.rdl");
    iconsRes.addIcons("main toolbar icons", "main_toolbar_icons.rdl");

// icons.rdl ---------------------------------------------------------------------------------------

    const folder = iconsRes.getIcon("icons", "folder");

    assertEquals(folder.group, "icons");
    assertEquals(folder.name, "folder");

    with (folder.texCoord) {
        assertEquals(offset.x, 30);
        assertEquals(offset.y, 9);
        assertEquals(size.x, 18);
        assertEquals(size.y, 18);
    }

    const material = iconsRes.getIcon("icons", "material");

    with (material.texCoord) {
        assertEquals(offset.x, 72);
        assertEquals(offset.y, 72);
    }

    const check = iconsRes.getIcon("icons", "check");

    with (check.texCoord) {
        assertEquals(offset.x, 114);
        assertEquals(offset.y, 30);
    }

// main_toolbar_icons.rdl --------------------------------------------------------------------------

    const wave = iconsRes.getIcon("main toolbar icons", "wave");

    with (wave.texCoord) {
        assertEquals(offset.x, 148);
        assertEquals(offset.y, 50);
        assertEquals(size.x, 48);
        assertEquals(size.y, 48);
    }

    const arc = iconsRes.getIcon("main toolbar icons", "arc");

    with (arc.texCoord) {
        assertEquals(offset.x, 50);
        assertEquals(offset.y, 99);
    }
}

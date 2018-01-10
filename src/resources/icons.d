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
    vec2 offset;
    vec2 size;
}

class IconsRes {
    this(ImagesRes imagesRes) {
        assert(imagesRes !is null);
        this.imagesRes = imagesRes;
        this.app = Application.getInstance();
    }

    Texture getTextureForIcons(in string icons) {
        // return this.imagesRes.getTextureForUiTheme(buildPath("icons", icons));
        return null; // TODO: implement
    }

    Icon getIcon(in string group) {
        return Icon(); // TODO: implement
    }

    void addIcons(in string fileName) {
        const path = buildPath(app.resourcesDirectory, "ui", "icons");
        iconsData[fileName] = new RPDLTree(path);
        iconsData[fileName].load(fileName);
    }

private:
    Application app;
    ImagesRes imagesRes;
    RPDLTree[string] iconsData;
}

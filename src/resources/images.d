/**
 * Copyright: © 2017 RedGoosePaws
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 * Authors: Andrey Kabylin
 */

module resources.images;

import std.path;
import application;
import gapi.texture;
import path;

/**
 * Get textures from files.
 */
final class ImagesRes {
    const Pathes pathes;

    this(in Pathes pathes, in string uiTheme = "") {
        this.pathes = pathes;
        this.uiTheme = uiTheme;
    }

    /**
     * Method loads the texture from `fileName` relative to $(I res/images).
     */
    Texture getTexture(in string fileName) {
        const key = "res:" ~ fileName;

        if (fileName !in textures) {
            const path = buildPath(pathes.resources, "images", fileName);
            textures[key] = new Texture(path);
        }

        return textures[key];
    }

    /**
     * Method loads the texture from `fileName` for current UI theme
     * i.e. relative to $(I res/ui/themes/images/{theme name}/images).
     */
    Texture getTextureForUiTheme(in string fileName) {
        debug assert(uiTheme != "");
        const key = "ui:" ~ fileName;

        if (fileName !in textures) {
            const path = buildPath(pathes.resources, "ui", "themes",
                                   uiTheme, "images", fileName);

            textures[key] = new Texture(path);
        }

        return textures[key];
    }

    /**
     * Method loads the texture from `fileName` which is absolute path.
     */
    Texture getTextureFromAbsolutePath(in string fileName) {
        const key = "absolute:" ~ fileName;

        if (fileName !in textures) {
            textures[key] = new Texture(fileName);
        }

        return textures[key];
    }

private:
    Texture[string] textures;
    string uiTheme;
}

///
@("Should not throw any exception when loading resources")
unittest {
    const pathes = initPathes();
    auto res = new ImagesRes(pathes, "light");

    // TODO: encapsulate
    import derelict.sfml2.graphics;
    DerelictSFML2Graphics.load();

    res.getTexture(buildPath("icons", "main_toolbar_icons.png"));
    res.getTextureForUiTheme(buildPath("icons", "icons.png"));
    res.getTextureFromAbsolutePath(buildPath(pathes.resources, "images", "icons", "main_toolbar_icons.png"));
}

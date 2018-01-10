/**
 * Copyright: © 2017 RedGoosePaws
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 * Authors: Andrey Kabylin
 */

module resources.images;

import std.path;
import application;
import gapi.texture;

/**
 * Get textures from files.
 */
final class ImagesRes {
    this(in string uiTheme = "") {
        app = Application.getInstance();
        this.uiTheme = uiTheme;
    }

    /**
     * Method loads the texture from `fileName` relative to $(I res/images).
     */
    Texture getTexture(in string fileName) {
        const key = "res:" ~ fileName;

        if (fileName !in textures) {
            const path = buildPath(app.resourcesDirectory, "images", fileName);
            textures[key] = new gapi.Texture(path);
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
            const path = buildPath(app.resourcesDirectory, "ui", "themes",
                                   uiTheme, "images", fileName);

            textures[key] = new gapi.Texture(path);
        }

        return textures[key];
    }

    /**
     * Method loads the texture from `fileName` which is absolute path.
     */
    Texture getTextureFromAbsolutePath(in string fileName) {
        const key = "absolute:" ~ fileName;

        if (fileName !in textures) {
            textures[key] = new gapi.Texture(fileName);
        }

        return textures[key];
    }

private:
    Application app;
    Texture[string] textures;
    string uiTheme;
}


///
unittest {
    import test.core;
    initApp();

    auto res = new ImagesRes("light");
    auto app = Application.getInstance();

    res.getTexture(buildPath("icons", "main_toolbar_icons.png"));
    res.getTextureForUiTheme(buildPath("icons", "icons.png"));
    res.getTextureFromAbsolutePath(buildPath(app.resourcesDirectory, "images", "icons", "main_toolbar_icons.png"));
}

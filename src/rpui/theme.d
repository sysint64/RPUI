/**
 * Theme data
 *
 * Copyright: © 2017 RedGoosePaws
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 * Authors: Andrey Kabylin
 */

module rpui.theme;

import std.path;
import std.file;
import std.exception;
import application;
import rpdl;
import gapi;

class ThemeFont : Font {
    this(in string fileName, in uint fontSize) {
        super(fileName);
        this.p_defaultFontSize = fontSize;
    }

    /// Create font from file relative to resources/fonts directory
    static ThemeFont createFromFile(in string relativeFileName, in uint fontSize) {
        Application app = Application.getInstance();
        const string absoluteFileName = buildPath(
            app.resourcesDirectory, "fonts",
            relativeFileName
        );
        ThemeFont font = new ThemeFont(absoluteFileName, fontSize);
        return font;
    }

    @property uint defaultFontSize() { return p_defaultFontSize; }

private:
    uint p_defaultFontSize;
}

class Theme {
    this(in string theme) {
        app = Application.getInstance();

        if (!load(theme)) {
            load(app.settings.defaultTheme, true);
        }

        loadGeneral();
    }

    /**
     * Data which strores texture coordinates for boundaries of UI widgets
     * e.g. for button widget it will be texture coordinates of left, center
     * and right boundaries for different states - Leave, Enter, Click and Focus
     */
    @property RPDLTree tree() { return p_tree; }

    /// UI Elements texture
    @property Texture skin() { return p_skin; }
    @property ThemeFont regularFont() { return p_regularFont; }

private:
    RPDLTree p_tree;
    Texture p_skin;
    ThemeFont p_regularFont;

private:
    Application app;

    /**
     * Load theme by name from resources/ui/themes directory
     * Params:
     *     theme = name of theme
     *     critical = if true, then will be invoked `Application.criticalError` method
     *                if an error occurred while loading
     */
    bool load(in string theme, in bool critical = false) {
        string dir = buildPath(app.resourcesDirectory, "ui", "themes", theme);
        p_tree = new RPDLTree(dir);
        string msg = collectExceptionMsg(tree.load("theme.rdl"));
        bool isSuccess = msg is null;

        if (isSuccess) {
            loadSkin(theme);
        } else if (critical) {
            app.criticalError(msg);
        }

        return isSuccess;
    }

    /// Retrieve general information from theme such as font and font and font size
    void loadGeneral() {
        string regularFontFileName = tree.data.optString(
            "General.regularFont.0",
            "ttf-dejavu/DejaVuSans.ttf"
        );
        const regularFontSize = tree.data.optInteger("General.regularFont.1", 12);
        p_regularFont = ThemeFont.createFromFile(regularFontFileName, regularFontSize);
    }

    /**
     * Loading `theme` texture for UI elements
     * Params:
     *     theme = name of theme where texture is located
     *     critical = if true, then will be invoked `Application.criticalError` method
     *                if an error occurred while loading
     */
    bool loadSkin(in string theme, in bool critical = false) {
        const path = buildPath(app.resourcesDirectory, "ui", "themes", theme, "controls.png");
        p_skin = new gapi.Texture(path);
        return true;
    }
}

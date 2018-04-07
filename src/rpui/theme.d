/**
 * Theme data.
 *
 * Copyright: © 2017 Andrey Kabylin
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 */

module rpui.theme;

import std.path;
import std.file;
import std.exception;
import application;
import rpdl;
import gapi;

/// Font used for rendering texts in UI. Contains different sizes for this font.
class ThemeFont : Font {
    /// Create font instance from `fileName` and set default font size = `fontSize`.
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
    /**
     * Load theme data from `res/ui/themes/`. Theme is a dirrectory which contains
     * skin with different dpi sizes and theme.rdl file where declared boundaries
     * for widget e.g. for different states of button like leave, enter, click and focus.
     */
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
    @property RpdlTree tree() { return p_tree; }

    /// UI Elements texture
    @property Texture skin() { return p_skin; }
    @property ThemeFont regularFont() { return p_regularFont; }

private:
    RpdlTree p_tree;
    Texture p_skin;
    ThemeFont p_regularFont;
    Application app;

    /**
     * Load theme by name from resources/ui/themes directory
     *
     * Params:
     *     theme = name of theme
     *     critical = if true, then will be invoked `Application.criticalError` method
     *                if an error occurred while loading
     */
    bool load(in string theme, in bool critical = false) {
        const dir = buildPath(app.resourcesDirectory, "ui", "themes", theme);
        p_tree = new RpdlTree(dir);
        string msg = collectExceptionMsg(tree.load("theme.rdl"));
        const isSuccess = msg is null;

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
     *
     * Params:
     *     theme = name of theme where texture is located
     *     critical = if true, then will be invoked `Application.criticalError` method
     *                if an error occurred while loading
     */
    bool loadSkin(in string theme, in bool critical = false) {
        // TODO: handle errors
        const path = buildPath(app.resourcesDirectory, "ui", "themes", theme, "controls.png");
        p_skin = new gapi.Texture(path);
        return true;
    }
}

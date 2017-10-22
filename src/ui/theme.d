module ui.theme;

import accessors;
import std.path;
import std.file;
import std.exception;
import application;
import rpdl;
import gapi;


class ThemeFont : gapi.Font {
    this(in string fileName, in uint fontSize) {
        super(fileName);
        this.defaultFontSize = fontSize;
    }

    static ThemeFont createFromFile(in string relativeFileName, in uint fontSize) {
        Application app = Application.getInstance();
        const string absoluteFileName = buildPath(
            app.resourcesDirectory, "fonts",
            relativeFileName
        );
        ThemeFont font = new ThemeFont(absoluteFileName, fontSize);
        return font;
    }

private:
    @Read @Write("private")
    uint defaultFontSize_;

    mixin(GenerateFieldAccessors);
}


class Theme {
    this(in string theme) {
        app = Application.getInstance();

        if (!load(theme)) {
            load(app.settings.defaultTheme, true);
        }

        loadGeneral();
    }

private:
    @Read @Write("private") {
        RPDLTree tree_;
        Texture skin_;
        ThemeFont regularFont_;
    }

    mixin(GenerateFieldAccessors);

private:
    Application app;

    bool load(in string theme, in bool critical = false) {
        string dir = buildPath(app.resourcesDirectory, "ui", "themes", theme);
        tree = new RPDLTree(dir);
        string msg = collectExceptionMsg(tree.load("theme.rdl"));
        bool isSuccess = msg is null;

        if (isSuccess) {
            loadSkin(theme);
        } else if (critical) {
            app.criticalError(msg);
        }

        return isSuccess;
    }

    void loadGeneral() {
        string regularFontFileName = tree.data.optString(
            "General.regularFont.0",
            "ttf-dejavu/DejaVuSans.ttf"
        );
        uint regularFontSize = tree.data.optInteger("General.regularFont.1", 12);
        regularFont = ThemeFont.createFromFile(regularFontFileName, regularFontSize);
    }

    bool loadSkin(in string theme, in bool critical = false) {
        string path = buildPath(app.resourcesDirectory, "ui", "themes", theme, "controls.png");
        skin = new gapi.Texture(path);
        return true;
    }
}

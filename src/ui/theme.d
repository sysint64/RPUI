module ui.theme;

import std.path;
import std.file;
import std.exception;
import application;
import e2ml;
import gapi;


class ThemeFont : gapi.Font {
    this(in string fileName, in uint fontSize) {
        super(fileName);
        this.p_defaultFontSize = fontSize;
    }

    static ThemeFont createFromFile(in string relativeFileName, in uint fontSize) {
        Application app = Application.getInstance();
        const string absoluteFileName = buildPath(app.resourcesDirectory, "fonts",
                                                  relativeFileName);
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

    @property e2ml.Data data() { return p_data; }
    @property gapi.Texture skin() { return p_skin; }
    @property ThemeFont regularFont() { return p_regularFont; }

private:
    e2ml.Data p_data;
    gapi.Texture p_skin;
    ThemeFont p_regularFont;
    Application app;

    bool load(in string theme, in bool critical = false) {
        string dir = buildPath(app.resourcesDirectory, "ui", "themes", theme);
        p_data = new Data(dir);
        string msg = collectExceptionMsg(p_data.load("theme.e2t"));
        bool isSuccess = msg is null;

        if (isSuccess) {
            loadSkin(theme);
        } else if (critical) {
            app.criticalError(msg);
        }

        return isSuccess;
    }

    void loadGeneral() {
        string regularFontFileName = p_data.optString("General.regularFont.0", "ttf-dejavu/DejaVuSans.ttf");
        uint regularFontSize = p_data.optInteger("General.regularFont.1", 12);
        p_regularFont = ThemeFont.createFromFile(regularFontFileName, regularFontSize);
    }

    bool loadSkin(in string theme, in bool critical = false) {
        string path = buildPath(app.resourcesDirectory, "ui", "themes", theme, "controls.png");
        p_skin = new gapi.Texture(path);
        return true;
    }
}

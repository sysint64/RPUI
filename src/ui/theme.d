module ui.theme;

import std.path;
import std.file;
import std.exception;
import application;
import e2ml;
import gapi;


class Theme {
    this(in string theme) {
        app = Application.getInstance();

        if (!load(theme)) {
            load(app.settings.defaultTheme, true);
        }
    }

    @property e2ml.Data data() { return p_data; }
    @property gapi.Texture skin() { return p_skin; }

private:
    e2ml.Data p_data;
    gapi.Texture p_skin;
    Application app;

    bool load(in string theme, in bool critical = false) {
        string dir = buildPath(app.resourcesDirectory, "ui", "themes", theme);
        p_data = new Data(dir);
        string msg = collectExceptionMsg(p_data.load("controls.e2t"));
        bool isSuccess = msg is null;

        if (isSuccess) {
            loadSkin(theme);
        } else if (critical) {
            app.criticalError(msg);
        }

        return isSuccess;
    }

    bool loadSkin(in string theme, in bool critical = false) {
        string path = buildPath(app.resourcesDirectory, "ui", "themes", theme, "controls.png");
        p_skin = new gapi.Texture(path);
        return true;
    }
}

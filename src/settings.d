module settings;

import patterns.singleton;
import e2ml.data;


class Settings {
    mixin Singleton!(Settings);

    void load(in string rootDirectory, in string fileName) {
        data = new Data(rootDirectory);
        data.load(fileName);
    }

    @property uint OGLMajor() {
        return data.optInteger("General.opengl_version.0", 2);
    }

    @property uint OGLMinor() {
        return data.optInteger("General.opengl_version.1", 1);
    }

    @property string uiTheme() {
        return data.optString("General.theme.0", "dark");
    }

private:
    Data data;
}

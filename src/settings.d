module settings;

import patterns.singleton;
import rpdl;


class Settings {
    mixin Singleton!(Settings);
    private this() {}

    void load(in string rootDirectory, in string fileName) {
        data = new RPDLTree(rootDirectory);
        data.load(fileName);
    }

    @property bool VAOEXT() {
        return false;
    }

    @property uint OGLMajor() {
        return data.optInteger("General.opengl_version.0", 2);
    }

    @property uint OGLMinor() {
        return data.optInteger("General.opengl_version.1", 1);
    }

    @property string theme() {
        return data.optString("Appearance.theme.0", "dark");
    }

    @property string defaultTheme() {
        return "dark";
    }

    @property string font() {
        return data.optString("Appearance.font.0", "DejaVuSans");
    }

    @property uint textSize() {
        return data.optInteger("Appearance.font.1", 12);
    }

    @property string language() {
        return data.optString("General.language.0", "en");
    }

private:
    RPDLTree data;
}

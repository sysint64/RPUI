module settings;

import patterns.singleton;
import rpdl;


class Settings {
    mixin Singleton!(Settings);
    private this() {}

    void load(in string rootDirectory, in string fileName) {
        settings = new RPDLTree(rootDirectory);
        settings.load(fileName);
    }

    @property bool VAOEXT() {
        return false;
    }

    @property uint OGLMajor() {
        return settings.data.optInteger("General.opengl_version.0", 2);
    }

    @property uint OGLMinor() {
        return settings.data.optInteger("General.opengl_version.1", 1);
    }

    @property string theme() {
        return settings.data.optString("Appearance.theme.0", "dark");
    }

    @property string defaultTheme() {
        return "dark";
    }

    @property string font() {
        return settings.data.optString("Appearance.font.0", "DejaVuSans");
    }

    @property uint textSize() {
        return settings.data.optInteger("Appearance.font.1", 12);
    }

    @property string language() {
        return settings.data.optString("General.language.0", "en");
    }

private:
    RPDLTree settings;
}

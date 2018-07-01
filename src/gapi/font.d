module gapi.font;

import std.string;
import std.conv : to;
import std.path : buildPath;

import application;

import gapi.text;
import gapi.font_impl;
import gapi.font_ftgl_impl;
import gapi.font_sfml_impl;
import gapi.texture;

class Font {
    enum AntiAliasing { stretchAA, strictAA }

    AntiAliasing antiAliasing = AntiAliasing.stretchAA;

    this(in string fileName) {
        version (FTGLFont) {
            impl = new FontFTGLImpl();
        } else version(SFMLFont) {
            impl = new FontSFMLImpl();
        }

        if (!impl.createFont(handles, fileName)) {
            throw new Error("Can't load font '" ~ fileName ~ "'");
        }
    }

    static Font createFromFile(in string relativeFileName) {
        Application app = Application.getInstance();
        const string absoluteFileName = buildPath(
            app.resourcesDirectory, "fonts",
            relativeFileName
        );
        return new Font(absoluteFileName);
    }

    ~this() {
        impl.destroyFont(handles);
    }

    Texture getTexture(in uint characterSize) {
        return impl.getTexture(this);
    }

    void bind(Text text) {
        impl.bind(handles, text);
    }

    void update() {
        impl.update(this);
    }

private:
    FontImpl impl;

package:
    FontHandles handles;

    void setTextSize(in uint textSize) {
        impl.setTextSize(this, textSize);
    }
}

module gapi.font;

import std.string;
import std.conv;

import gapi.font_impl;
import gapi.font_ftgl_impl;
import gapi.font_sfml_impl;
import gapi.texture;


class Font {
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

    ~this() {
        impl.destroyFont(handles);
    }

    Texture getTexture(in uint characterSize) {
        return impl.getTexture(this);
    }

private:
    FontImpl impl;

package:
    FontHandles handles;

    void setTextSize(in uint textSize) {
        impl.setTextSize(this, textSize);
    }
}

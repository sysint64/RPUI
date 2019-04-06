module gapi.font_sdl_impl;

import gapi.font;
import gapi.text;
import gapi.texture;
import gapi.font_impl;

class FontSDLImpl : FontImpl {
    private Texture2D texture;

    bool createFont(ref FontHandles handles, in string fileName) {
        return false;
    }

    void destroyFont(ref FontHandles handles) {
    }

    void setTextSize(Font font, in uint textSize) {
    }

    Texture2D getTexture(Font font) {
        return texture;
    }

    void bind(ref FontHandles handles, Text text) {
    }

    void update(Font font) {
    }
}

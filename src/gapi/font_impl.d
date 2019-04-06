module gapi.font_impl;

import gapi.font;
import gapi.text;
import gapi.texture;

struct FontHandles {
    // sfFont* sfmlHandle;
}

interface FontImpl {
    bool createFont(ref FontHandles handles, in string fileName);

    void destroyFont(ref FontHandles handles);

    void setTextSize(Font font, in uint textSize);

    Texture2D getTexture(Font font);

    void bind(ref FontHandles handles, Text text);

    void update(Font font);
}

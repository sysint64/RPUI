module gapi.font_impl;

import ftgl;
import derelict.sfml2.graphics;

import gapi.font;
import gapi.texture;


struct FontHandles {
    sfFont* sfmlHandle;
    FTGLfont* ftglHandle;
}


interface FontImpl {
    bool createFont(ref FontHandles handles, in string fileName);
    void destroyFont(ref FontHandles handles);
    void setTextSize(Font font, in uint textSize);
    Texture getTexture(Font font);
}

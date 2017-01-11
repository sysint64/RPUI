module gapi.font_impl;

import ftgl;
import derelict.sfml2.graphics;

import gapi.texture;


struct FontHandles {
    sfFont* sfmlHandle;
    FTGLfont* ftglHandle;
}


interface FontImpl {
    FontHandles createFont(in string fileName);
    void setTextSize(in uint textSize);
    Texture getTexture();
}

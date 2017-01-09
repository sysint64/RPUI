module gapi.font_impl;

import gapi.texture;


interface FontImpl {
    Texture getTexture(in uint characterSize);
}

module gapi.text_impl;

import gapi.camera;


interface TextImpl {
    void render(in dstring text, Camera camera);
    size_t charIndexUnderPoint(in dstring text, in uint x, in uint y);
}

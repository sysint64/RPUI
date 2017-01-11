module gapi.text_impl;

import gapi.camera;
import gapi.font;

import math.linalg;


interface TextImpl {
    void render(in Font font, in dstring text, in vec3 color,in vec2 position, Camera camera);
    size_t charIndexUnderPoint(in Font font, in dstring text, in uint x, in uint y);
    vec2 charPositionUnderPoint(in Font font, in dstring text, in uint x, in uint y);
    uint getWidth(in Font font, in dstring text);
}

module gapi.text_impl;

import gapi.camera;
import gapi.font;
import gapi.text;

import math.linalg;

interface TextImpl {
    void render(Text textObject, Camera camera);
    size_t charIndexUnderPoint(Text textObject, in uint x, in uint y);
    vec2 charPositionUnderPoint(Text textObject, in uint x, in uint y);
    uint getWidth(Text textObject);
    uint getRegionTextWidth(Text textObject, in size_t start, in size_t end);
}

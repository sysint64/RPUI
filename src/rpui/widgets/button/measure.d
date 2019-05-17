module rpui.widgets.button.measure;

import rpdl;
import rpui.math;

struct Measure {
    float textWidth = 0;
    vec2 focusOffsets;
    float focusResize;
    float textLeftMargin;
    float textRightMargin;
    float iconGaps;
    vec2 iconOffsets;
    float iconsAreaSize = 0;
}

Measure readMeasure(RpdlNode data, in string style) {
    const focusKey = style ~ ".Focus";

    Measure measure = {
        focusOffsets: data.getVec2f(focusKey ~ ".offsets.0"),
        focusResize: data.getNumber(focusKey ~ ".offsets.1"),
        textLeftMargin: data.getNumber(style ~ ".textLeftMargin.0"),
        textRightMargin: data.getNumber(style ~ ".textRightMargin.0"),
        iconGaps: data.getNumber(style ~ ".iconGaps.0"),
        iconOffsets: data.getVec2f(style ~ ".iconOffsets")
    };
    return measure;
}

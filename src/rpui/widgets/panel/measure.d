module rpui.widgets.panel.measure;

import rpdl;
import rpui.math;
import rpui.widgets.panel;

struct Measure {
    // vec4[Panel.Background] backgroundColors;
    // float splitThickness;
    vec2 widgetsOffset;
    // vec4[SplitColor] spliltColors;
    float headerHeight;
    float scrollButtonMinSize;
    float horizontalScrollRegionWidth;
    float verticalScrollRegionWidth;
}

Measure readMeasure(RpdlNode data, in string style) {
    Measure measure = {
        scrollButtonMinSize: data.getNumber(style ~ ".Scroll.buttonMinSize.0"),
        horizontalScrollRegionWidth: data.getNumber(style ~ ".Scroll.Horizontal.regionWidth.0"),
        verticalScrollRegionWidth: data.getNumber(style ~ ".Scroll.Vertical.regionWidth.0"),
        headerHeight: data.getNumber(style ~ ".Header.height.0"),
        // splitThickness: data.getNumber(style ~ ".Split.thickness.0"),
    };
    return measure;
}

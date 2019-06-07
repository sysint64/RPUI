module rpui.widgets.panel.measure;

import rpdl;
import rpui.math;
import rpui.widgets.panel;

struct Measure {
    float headerHeight;
    float scrollButtonMinSize;
    float horizontalScrollRegionWidth;
    float verticalScrollRegionWidth;
    float splitThickness;
}

Measure readMeasure(RpdlNode data, in string style) {
    Measure measure = {
        scrollButtonMinSize: data.getNumber(style ~ ".Scroll.buttonMinSize.0"),
        horizontalScrollRegionWidth: data.getNumber(style ~ ".Scroll.Horizontal.regionWidth.0"),
        verticalScrollRegionWidth: data.getNumber(style ~ ".Scroll.Vertical.regionWidth.0"),
        headerHeight: data.getNumber(style ~ ".Header.height.0"),
        splitThickness: data.getNumber(style ~ ".Split.thickness.0"),
    };
    return measure;
}

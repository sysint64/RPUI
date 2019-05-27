module rpui.widgets.panel.measure;

import rpdl;
import rpui.math;
import rpui.widgets.panel;

struct Measure {
    // vec4[Panel.Background] backgroundColors;
    float splitThickness;
    vec2 widgetsOffset;
    // vec4[SplitColor] spliltColors;
    float headerHeight;
}

Measure readMeasure(RpdlNode data, in string style) {
    Measure measure = {
        splitThickness: data.getNumber(style ~ ".Split.thickness.0"),
    };
    return measure;
}

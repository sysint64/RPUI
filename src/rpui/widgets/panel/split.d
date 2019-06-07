module rpui.widgets.panel.split;

import rpui.basic_types;

struct Split {
    bool isClick;
    bool isEnter;
    float cursorRangeSize = 8;
    Rect cursorRangeRect;
    float thickness;
}

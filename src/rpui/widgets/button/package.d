module rpui.widgets.button;

import std.container.array;

import rpui.basic_types;
import rpui.widget;
import rpui.view;

class Button : Widget {
    @field bool allowCheck = false;
    @field Align textAlign = Align.center;
    @field VerticalAlign textVerticalAlign = VerticalAlign.middle;
    @field Array!string icons;
}

module rpui.alignment;

import std.math;

enum RegionAlign {
    none,
    left,
    right,
    top,
    bottom,
    client,
}

enum Align {
    none,
    left,
    center,
    right,
}

enum VerticalAlign {
    none,
    top,
    middle,
    bottom,
}

float alignBox(in Align align_, in float width, in float containerWidth) {
    switch (align_) {
        case Align.center:
            return round((containerWidth - width) * 0.5);

        case Align.right:
            return containerWidth - width;

        default:
            return 0;
    }
}

float verticalAlignBox(in VerticalAlign verticalAlign, in float height, in float containerHeight) {
    switch (verticalAlign) {
        case VerticalAlign.bottom:
            return containerHeight - height;

        case VerticalAlign.middle:
            return round((containerHeight - height) * 0.5);

        default:
            return 0;
    }
}

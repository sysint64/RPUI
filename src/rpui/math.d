module rpui.math;

import rpui.basic_types;
import gapi.vec;

bool pointInRect(in vec2i point, in vec4 vec) {
    const Rect rect = Rect(vec);
    return pointInRect(point, rect);
}

bool pointInRect(in vec2i point, in Rect rect) {
    return (point.x <= rect.left+rect.width ) && (point.x >= rect.left) &&
           (point.y <= rect.top +rect.height) && (point.y >= rect.top);
}

/// Clamp version without assertions.
auto unsafeClamp(T1, T2, T3)(T1 val, T2 lower, T3 upper) {
    if (val < lower) return lower;
    if (val > upper) return upper;
    return val;
}

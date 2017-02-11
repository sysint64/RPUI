module basic_types;

import math.linalg;


alias utfchar = dchar;
alias utfstring = dstring;

enum Align {
    none,
    left,
    center,
    right,
    client,
};

enum VerticalAlign {
    none,
    top,
    middle,
    bottom,
    client,
}

struct FrameRect {
    float left;
    float right;
    float top;
    float bottom;

    this(in float left, in float top, in float right, in float bottom) {
        this.left = left;
        this.top = top;
        this.right = right;
        this.bottom = bottom;
    }

    this(in vec4 rect) {
        this.left = rect.x;
        this.top = rect.y;
        this.right = rect.z;
        this.bottom = rect.w;
    }
}

struct Rect {
    float left;
    float top;
    float width;
    float height;

    this(in float left, in float top, in float width, in float height) {
        this.left = left;
        this.top = top;
        this.width = width;
        this.height = height;
    }

    this(in vec4 rect) {
        this.left = rect.x;
        this.top = rect.y;
        this.width = rect.z;
        this.height = rect.w;
    }
}

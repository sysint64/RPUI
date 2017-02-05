module basic_types;

import math.linalg;


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

struct Rect {
    uint left;
    uint top;
    uint width;
    uint height;

    this(in uint left, in uint top, in uint width, in uint height) {
        this.left = left;
        this.top = top;
        this.width = width;
        this.height = height;
    }

    this(in vec4i rect) {
        this.left = rect.x;
        this.top = rect.y;
        this.width = rect.z;
        this.height = rect.w;
    }
}

module ui.scroll;

// import std.algorithm.comparison;
import std.math;

import application;
import basic_types;
import input;


private auto clamp(T1, T2, T3)(T1 val, T2 lower, T3 upper)
{
    if (val < lower) return lower;
    if (val > upper) return upper;
    return val;
}


class ScrollController {
    this(in Orientation orientation) {
        app = Application.getInstance();
        this.orientation = orientation;
    }

    void pollButton() {
        const float buttonRatio = p_buttonMaxSize / p_contentSize;
        p_buttonSize = p_buttonMaxSize * buttonRatio;

        if (!p_buttonClick)
            return;

        if (orientation == Orientation.horizontal)
            p_buttonOffset = buttonClickOffset + app.mousePos.x - app.mouseClickPos.x;

        if (orientation == Orientation.vertical)
            p_buttonOffset = buttonClickOffset + app.mousePos.y - app.mouseClickPos.y;

        p_buttonOffset = clamp(p_buttonOffset, p_buttonMinOffset,
                               p_buttonMaxOffset - p_buttonSize);

        const float contentRatio = p_buttonOffset / p_buttonMaxOffset;
        p_contentOffset = p_contentSize * contentRatio;
    }

    void onResize() {
        const float ratio = p_contentOffset / p_contentSize;
        p_buttonOffset = p_buttonMaxSize * ratio;

        p_buttonOffset = clamp(p_buttonOffset, 0, p_buttonMaxOffset - p_buttonSize);
        p_contentOffset = clamp(p_contentOffset, 0, p_contentMaxOffset);
    }

    void onMouseWheel(in int dx, in int dy) {
    }

    void onMouseDown(in uint x, in uint y, in MouseButton button) {
        buttonClickOffset = p_buttonOffset;
    }

    @property float buttonSize() { return p_buttonSize; }
    @property float buttonOffset() { return p_buttonOffset; }

    @property float buttonMinSize() { return p_buttonMinSize; }
    @property void buttonMinSize(in float val) { p_buttonMinSize = val; }

    @property float buttonMaxSize() { return p_buttonMaxSize; }
    @property void buttonMaxSize(in float val) { p_buttonMaxSize = val; }

    @property float buttonMinOffset() { return p_buttonMinOffset; }
    @property void buttonMinOffset(in float val) { p_buttonMinOffset = val; }

    @property float buttonMaxOffset() { return p_buttonMaxOffset; }
    @property void buttonMaxOffset(in float val) { p_buttonMaxOffset = val; }

    @property bool buttonClick() { return p_buttonClick; }
    @property void buttonClick(in bool val) { p_buttonClick = val; }

    @property float contentSize() { return p_contentSize; }
    @property void contentSize(in float val) { p_contentSize = val; }

    @property float contentOffset() { return p_contentOffset; }

    @property float contentMaxOffset() { return p_contentMaxOffset; }
    @property void contentMaxOffset(in float val) { p_contentMaxOffset = val; }

private:
    Application app;

    float p_buttonMinOffset = 0;
    float p_buttonMaxOffset = 0;
    float p_buttonMinSize;
    float p_buttonMaxSize;

    float p_buttonOffset = 0;
    float p_buttonSize = 0;
    bool  p_buttonClick = false;

    float p_contentMaxOffset = 0;
    float p_contentOffset = 0;
    float p_contentSize = 0;

    Orientation orientation;
    float buttonClickOffset;
}

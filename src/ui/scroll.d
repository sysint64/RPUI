module ui.scroll;

// import std.algorithm.comparison;
import std.math;
import std.conv : to;

import application;
import basic_types;
import input;


private auto clamp(T1, T2, T3)(T1 val, T2 lower, T3 upper)
{
    if (val < lower) return lower;
    if (val > upper) return upper;
    return val;
}


interface Scrollable {
    void onMouseWheelHandle(in int dx, in int dy);
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

        clampValues();
        const float contentRatio = p_buttonOffset / p_buttonMaxOffset;
        p_contentOffset = p_contentSize * contentRatio;
    }

    void onResize() {
        const float ratio = p_contentOffset / p_contentSize;
        p_buttonOffset = p_buttonMaxSize * ratio;
        clampValues();
    }

    void onMouseDown(in uint x, in uint y, in MouseButton button) {
        buttonClickOffset = p_buttonOffset;
    }

    bool addOffsetInPx(in float delta) {
        const float lastScrollOffset = p_contentOffset;
        p_contentOffset += delta;
        onResize();
        clampValues();
        return lastScrollOffset != p_contentOffset;
    }

    @property float buttonSize() { return ceil(p_buttonSize); }
    @property float buttonOffset() { return ceil(p_buttonOffset); }

    @property float buttonMinSize() { return ceil(p_buttonMinSize); }
    @property void buttonMinSize(in float val) { p_buttonMinSize = val; }

    @property float buttonMaxSize() { return ceil(p_buttonMaxSize); }
    @property void buttonMaxSize(in float val) { p_buttonMaxSize = val; }

    @property float buttonMinOffset() { return ceil(p_buttonMinOffset); }
    @property void buttonMinOffset(in float val) { p_buttonMinOffset = val; }

    @property float buttonMaxOffset() { return ceil(p_buttonMaxOffset); }
    @property void buttonMaxOffset(in float val) { p_buttonMaxOffset = val; }

    @property bool buttonClick() { return p_buttonClick; }
    @property void buttonClick(in bool val) { p_buttonClick = val; }

    @property float contentSize() { return ceil(p_contentSize); }
    @property void contentSize(in float val) { p_contentSize = val; }

    @property float contentOffset() { return ceil(p_contentOffset); }

    @property float contentMaxOffset() { return ceil(p_contentMaxOffset); }
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

    private void clampValues() {
        p_buttonOffset = clamp(p_buttonOffset, 0, p_buttonMaxOffset - p_buttonSize);
        p_contentOffset = clamp(p_contentOffset, 0, p_contentMaxOffset);
    }
}

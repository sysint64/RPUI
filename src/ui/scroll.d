module ui.scroll;

// import std.algorithm.comparison;
import std.math;
import std.conv : to;

import application;
import basic_types;
import input;


private auto clamp(T1, T2, T3)(T1 val, T2 lower, T3 upper) {
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
        const float buttonRatio = buttonMaxSize / contentSize;
        p_buttonSize = buttonMaxSize * buttonRatio;

        if (!buttonClick)
            return;

        if (orientation == Orientation.horizontal)
            p_buttonOffset = buttonClickOffset + app.mousePos.x - app.mouseClickPos.x;

        if (orientation == Orientation.vertical)
            p_buttonOffset = buttonClickOffset + app.mousePos.y - app.mouseClickPos.y;

        clampValues();
        const float contentRatio = p_buttonOffset / buttonMaxOffset;
        p_contentOffset = contentSize * contentRatio;
    }

    void onResize() {
        if (p_contentOffset == 0)
            return;

        const float ratio = p_contentOffset / contentSize;
        p_buttonOffset = buttonMaxSize * ratio;
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

// Properties --------------------------------------------------------------------------------------

    float buttonMinOffset = 0;
    float buttonMaxOffset = 0;
    float buttonMinSize;
    float buttonMaxSize;
    bool  buttonClick = false;
    float contentMaxOffset = 0;
    float contentSize = 0;

    @property float buttonSize() { return ceil(p_buttonSize); }
    @property float buttonOffset() { return ceil(p_buttonOffset); }
    @property float contentOffset() { return ceil(p_contentOffset); }

private:
    float p_buttonOffset = 0;
    float p_buttonSize = 0;
    float p_contentOffset = 0;

    Application app;

    Orientation orientation;
    float buttonClickOffset;

    void clampValues() {
        p_buttonOffset = clamp(p_buttonOffset, 0, buttonMaxOffset - p_buttonSize);
        p_contentOffset = clamp(p_contentOffset, 0, contentMaxOffset);
    }
}

module ui.scroll;

// import std.algorithm.comparison;
import std.math;
import std.conv : to;

import accessors;
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
        const float buttonRatio = buttonMaxSize / contentSize;
        buttonSize_ = buttonMaxSize * buttonRatio;

        if (!buttonClick)
            return;

        if (orientation == Orientation.horizontal)
            buttonOffset_ = buttonClickOffset + app.mousePos.x - app.mouseClickPos.x;

        if (orientation == Orientation.vertical)
            buttonOffset_ = buttonClickOffset + app.mousePos.y - app.mouseClickPos.y;

        clampValues();
        const float contentRatio = buttonOffset_ / buttonMaxOffset;
        contentOffset_ = contentSize * contentRatio;
    }

    void onResize() {
        if (contentOffset_ == 0)
            return;

        const float ratio = contentOffset_ / contentSize;
        buttonOffset_ = buttonMaxSize * ratio;
        clampValues();
    }

    void onMouseDown(in uint x, in uint y, in MouseButton button) {
        buttonClickOffset = buttonOffset_;
    }

    bool addOffsetInPx(in float delta) {
        const float lastScrollOffset = contentOffset_;
        contentOffset_ += delta;
        onResize();
        clampValues();
        return lastScrollOffset != contentOffset_;
    }

// Properties --------------------------------------------------------------------------------------

private:
    @Read @Write {
        float buttonMinOffset_ = 0;
        float buttonMaxOffset_ = 0;
        float buttonMinSize_;
        float buttonMaxSize_;
        bool  buttonClick_ = false;
        float contentMaxOffset_ = 0;
        float contentSize_ = 0;
    }

    float buttonOffset_ = 0;
    float buttonSize_ = 0;
    float contentOffset_ = 0;

    public @property {
        float buttonSize() { return ceil(buttonSize_); }
        float buttonOffset() { return ceil(buttonOffset_); }
        float contentOffset() { return ceil(contentOffset_); }
    }

    mixin(GenerateFieldAccessors);

private:
    Application app;

    Orientation orientation;
    float buttonClickOffset;

    private void clampValues() {
        buttonOffset_ = clamp(buttonOffset_, 0, buttonMaxOffset - buttonSize_);
        contentOffset_ = clamp(contentOffset_, 0, contentMaxOffset);
    }
}

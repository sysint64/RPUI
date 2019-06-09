module rpui.scroll;

import std.math;
import std.conv : to;

import rpui.primitives;
import rpui.input;
import rpui.events;
import rpui.math;

/**
 * Describe interface for scrollable widgets, this controller computes content
 * offsets and scroll button size and offset depending of the `contentSize` and
 * and `visibleSize`. See how to use this controller in `rpui.widgets.panel.Panel`.
 */
struct ScrollController {
    float buttonMaxOffset = 0;
    float buttonMinSize = 20;
    float buttonMaxSize;
    bool  buttonClick = false;  /// If true, then user clicked button and hold it.
    float contentMaxOffset = 0;
    float contentSize = 0;  /// Full content size.
    float visibleSize = 0;  /// Visible area size.

    /// Calculated button size.
    @property float buttonSize() { return ceil(buttonSize_); }
    private float buttonSize_ = 0;

    /// Calculated button offset.
    @property float buttonOffset() { return ceil(buttonOffset_); }
    private float buttonOffset_ = 0;

    /// Calculated content offset.
    @property float contentOffset() { return ceil(contentOffset_); }
    private float contentOffset_ = 0;

    private Orientation orientation;
    private float buttonClickOffset;

    /// Create controller with orientation - vertical or horizontal.
    this(in Orientation orientation) {
        this.orientation = orientation;
    }

    /// Calculates `buttonSize`, `buttonOffset` and `contentOffset`.
    void pollButton(in vec2i mousePos, in vec2i mouseClickPos) {
        const float buttonRatio = visibleSize / contentSize;
        buttonSize_ = buttonMaxSize * buttonRatio;

        if (buttonSize_ < buttonMinSize)
            buttonSize_ = buttonMinSize;

        if (!buttonClick) {
            clampValues();
            return;
        }

        float delta = 0;

        if (orientation == Orientation.horizontal)
            delta = mousePos.x - mouseClickPos.x;

        if (orientation == Orientation.vertical)
            delta = mousePos.y - mouseClickPos.y;

        buttonOffset_ = buttonClickOffset + delta;
        clampValues();
        const float contentRatio = buttonOffset_ / (buttonMaxSize - buttonSize_);
        contentOffset_ = contentMaxOffset * contentRatio;
    }

    /// Update parameters when widget update size.
    void onResize() {
        if (contentMaxOffset == 0) {
            buttonOffset_ = 0;
        } else {
            const float ratio = contentOffset_ / contentMaxOffset;
            buttonOffset_ = (buttonMaxSize - buttonSize_) * ratio;
        }

        clampValues();
    }

    void onMouseDown(in MouseDownEvent event) {
        buttonClickOffset = buttonOffset_;
    }

    bool addOffsetInPx(in float delta) {
        if (visibleSize >= contentSize)
            return false;

        const float lastScrollOffset = contentOffset_;
        contentOffset_ += delta;
        onResize();
        return lastScrollOffset != contentOffset_;
    }

    bool setOffsetInPx(in float pixels) {
        const float lastScrollOffset = contentOffset_;
        contentOffset_ = pixels;
        onResize();
        return lastScrollOffset != contentOffset_;
    }

    /// Set content offset in `percent`, value should be in 0..1 range.
    void setOffsetInPercent(in float percent)
    in {
        assert(percent <= 1.0f, "percent should be in range 0..1");
    }
    body {
        contentOffset_ = contentMaxOffset * percent;
        onResize();
    }

    private void clampValues() {
        buttonOffset_ = unsafeClamp(buttonOffset_, 0, buttonMaxOffset - buttonSize_);
        contentOffset_ = unsafeClamp(contentOffset_, 0, contentMaxOffset);
    }
}

/**
 * Scroll controller for widgets like `rpui.widgets.panel.Panel`.
 *
 * Copyright: © 2017 RedGoosePaws
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 * Authors: Andrey Kabylin
 */

module rpui.scroll;

import std.math;
import std.conv : to;

import application;
import basic_types;
import input;
import rpui.events;

/// Clamp version without assertions.
private auto clamp(T1, T2, T3)(T1 val, T2 lower, T3 upper) {
    if (val < lower) return lower;
    if (val > upper) return upper;
    return val;
}

/**
 * Describe interface for scrollable widgets, this controller computes content
 * offsets and scroll button size and offset depending of the `contentSize` and
 * and `visibleSize`. See how to use this controller in `rpui.widgets.panel.Panel`.
 */
class ScrollController {
    /// Create controller with orientation - vertical or horizontal.
    this(in Orientation orientation) {
        app = Application.getInstance();
        this.orientation = orientation;
    }

    /// Calculates `buttonSize`, `buttonOffset` and `contentOffset`.
    void pollButton() {
        const float buttonRatio = visibleSize / contentSize;
        p_buttonSize = buttonMaxSize * buttonRatio;

        if (p_buttonSize < buttonMinSize)
            p_buttonSize = buttonMinSize;

        if (!buttonClick) {
            clampValues();
            return;
        }

        float delta = 0;

        if (orientation == Orientation.horizontal)
            delta = app.mousePos.x - app.mouseClickPos.x;

        if (orientation == Orientation.vertical)
            delta = app.mousePos.y - app.mouseClickPos.y;

        p_buttonOffset = buttonClickOffset + delta;
        clampValues();
        const float contentRatio = p_buttonOffset / (buttonMaxSize - p_buttonSize);
        p_contentOffset = contentMaxOffset * contentRatio;
    }

    /// Update parameters when widget update size.
    void onResize() {
        if (contentMaxOffset == 0) {
            p_buttonOffset = 0;
        } else {
            const float ratio = p_contentOffset / contentMaxOffset;
            p_buttonOffset = (buttonMaxSize - p_buttonSize) * ratio;
        }

        clampValues();
    }

    void onMouseDown(in MouseDownEvent event) {
        buttonClickOffset = p_buttonOffset;
    }

    bool addOffsetInPx(in float delta) {
        if (visibleSize >= contentSize)
            return false;

        const float lastScrollOffset = p_contentOffset;
        p_contentOffset += delta;
        onResize();
        return lastScrollOffset != p_contentOffset;
    }

    bool setOffsetInPx(in float pixels) {
        const float lastScrollOffset = p_contentOffset;
        p_contentOffset = pixels;
        onResize();
        return lastScrollOffset != p_contentOffset;
    }

    /// Set content offset in `percent`, value should be in 0..1 range.
    void setOffsetInPercent(in float percent)
    in {
        assert(percent <= 1.0f, "percent should be in range 0..1");
    }
    body {
        p_contentOffset = contentMaxOffset * percent;
        onResize();
    }

// Properties --------------------------------------------------------------------------------------

    float buttonMaxOffset = 0;
    float buttonMinSize = 20;
    float buttonMaxSize;
    bool  buttonClick = false;  /// If true, then user clicked button and hold it.
    float contentMaxOffset = 0;
    float contentSize = 0;  /// Full content size.
    float visibleSize = 0;  /// Visible area size.

    /// Calculated button size.
    @property float buttonSize() { return ceil(p_buttonSize); }

    /// Calculated button offset.
    @property float buttonOffset() { return ceil(p_buttonOffset); }

    /// Calculated content offset.
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

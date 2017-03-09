module ui.scroll;

import std.algorithm.comparison;
import application;
import basic_types;
import input;


class ScrollController {
    this(in Orientation orientation) {
        app = Application.getInstance();
        this.orientation = orientation;
    }

    void pollButton() {
        if (orientation == Orientation.horizontal)
            p_buttonOffset = buttonClickOffset + app.mousePos.x - app.mouseClickPos.x;

        if (orientation == Orientation.vertical)
            p_buttonOffset = buttonClickOffset + app.mousePos.y - app.mouseClickPos.y;

        p_buttonOffset = clamp(p_buttonOffset, p_buttonMinOffset,
                               p_buttonMaxOffset - p_buttonSize);
    }

    void onResize() {
    }

    void onMouseWheel(in int dx, in int dy) {
    }

    void onMouseDown(in uint x, in uint y, in MouseButton button) {
        buttonClickOffset = p_buttonOffset;
    }

    @property float buttonSize() { return p_buttonSize; }
    @property float buttonOffset() { return p_buttonOffset; }

    @property float contentSize() { return p_contentSize; }
    @property void contentSize(in float val) { p_contentSize = val; }

    @property float buttonMinSize() { return p_buttonMinSize; }
    @property void buttonMinSize(in float val) { p_buttonMinSize = val; }

    @property float buttonMaxSize() { return p_buttonMaxSize; }
    @property void buttonMaxSize(in float val) { p_buttonMaxSize = val; }

    @property float buttonMinOffset() { return p_buttonMinOffset; }
    @property void buttonMinOffset(in float val) { p_buttonMinOffset = val; }

    @property float buttonMaxOffset() { return p_buttonMaxOffset; }
    @property void buttonMaxOffset(in float val) { p_buttonMaxOffset = val; }

private:
    Application app;

    float p_contentSize;
    float p_buttonMinOffset = 0;
    float p_buttonMaxOffset = 1000;
    float p_buttonMinSize;
    float p_buttonMaxSize;

    float p_buttonOffset = 0;
    float p_buttonSize = 50;

    Orientation orientation;
    float buttonClickOffset;
}

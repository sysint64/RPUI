module rpui.widgets.panel.scroll_button;

import rpui.scroll;
import rpui.math;
import rpui.widgets.panel.widget;
import rpui.primitives;
import rpui.render.components : State;

struct ScrollButton {
    Orientation orientation;
    ScrollController scrollController;
    float regionWidth;
    bool isEnter = false;
    bool isClick = false;
    bool visible = false;
    vec2 buttonOffset;
    float buttonSize;
    Panel panel;
    float width;

    @property inout(State) state() inout {
        if (isClick) {
            return State.click;
        } else if (isEnter) {
            return State.enter;
        } else {
            return State.leave;
        }
    }

    this(in Orientation orientation) {
        this.orientation = orientation;
        this.scrollController = ScrollController(orientation);
    }

    void updateController() {
        float widgetRegionSizes(in Orientation orientation) {
            if (orientation == Orientation.horizontal) {
                return panel.extraInnerOffset.left + panel.extraInnerOffset.right;
            } else {
                return panel.extraInnerOffset.top + panel.extraInnerOffset.bottom;
            }
        }

        float getVectorComponent(in vec2 vector) {
            return orientation == Orientation.horizontal ? vector.x : vector.y;
        }

        const widgetSize = getVectorComponent(panel.size);
        const widgetRegionSize = widgetRegionSizes(orientation);
        const innerBoundarySize = getVectorComponent(panel.innerBoundarySize);
        const innerBoundarySizeClamped = getVectorComponent(panel.innerBoundarySizeClamped);

        with (scrollController) {
            buttonMaxOffset = widgetSize - widgetRegionSize;
            buttonMaxSize = widgetSize - widgetRegionSize;
            buttonClick = isClick;

            visibleSize = widgetSize;
            contentSize = innerBoundarySize;
            contentMaxOffset = innerBoundarySizeClamped - widgetSize;
        }
    }

    void attach(Panel panel) {
        this.panel = panel;
        this.scrollController.buttonMinSize = panel.measure.scrollButtonMinSize;

        if (orientation == Orientation.horizontal) {
            this.width = panel.measure.horizontalScrollRegionWidth;
        }
        else if (orientation == Orientation.vertical) {
            this.width = panel.measure.verticalScrollRegionWidth;
        }
    }

    void updateSize() {
        updateController();
        visible = scrollController.contentSize > scrollController.visibleSize;

        if (orientation == Orientation.horizontal) {
            buttonSize = scrollController.buttonSize;
            buttonOffset = vec2(
                scrollController.buttonOffset,
                panel.size.y - width
            );
        }
        else if (orientation == Orientation.vertical) {
            buttonSize = scrollController.buttonSize;
            buttonOffset = vec2(
                panel.size.x - width,
                scrollController.buttonOffset + panel.extraInnerOffset.top
            );
        }

        if (!visible) {
            scrollController.setOffsetInPercent(0);
            return;
        }

        scrollController.pollButton(panel.view.mousePos, panel.view.mouseClickPos);
    }

    void onProgress() {
        Rect rect;

        if (orientation == Orientation.horizontal) {
            rect = Rect(
                panel.absolutePosition + buttonOffset,
                vec2(buttonSize, panel.extraInnerOffset.bottom)
            );
        }
        else if (orientation == Orientation.vertical) {
            rect = Rect(
                panel.absolutePosition + buttonOffset,
                vec2(panel.extraInnerOffset.right, buttonSize)
            );
        }

        isEnter = pointInRect(panel.view.mousePos, rect);
    }
}

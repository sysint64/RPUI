module rpui.widgets.panel.scroll_button;

import rpui.scroll;
import rpui.math;
import rpui.widgets.panel;
import rpui.basic_types;

struct ScrollButton {
    Orientation orientation;
    ScrollController scrollController;
    float regionWidth;
    bool isEnter = false;
    bool isClick = false;
    bool visible = false;
    vec2 buttonOffset;
    float buttonSize;

    this(in Orientation orientation) {
        this.orientation = orientation;
    }
}

ScrollController updateController(Panel panel, in ScrollButton scrollButton) {
    ScrollController scrollController;

    const float[Orientation] widgetRegionSizes = [
        Orientation.horizontal: panel.extraInnerOffset.left + panel.extraInnerOffset.right,
        Orientation.vertical: panel.extraInnerOffset.top + panel.extraInnerOffset.bottom
    ];

    float getVectorComponent(in vec2 vector) {
        return scrollButton.orientation == Orientation.horizontal ? vector.x : vector.y;
    }

    const widgetSize = getVectorComponent(panel.size);
    const widgetRegionSize = widgetRegionSizes[scrollButton.orientation];
    const innerBoundarySize = getVectorComponent(panel.innerBoundarySize);
    const innerBoundarySizeClamped = getVectorComponent(panel.innerBoundarySizeClamped);

    with (scrollController) {
        buttonMaxOffset = widgetSize - widgetRegionSize;
        buttonMaxSize = widgetSize - widgetRegionSize;
        buttonClick = scrollButton.isClick;

        visibleSize = widgetSize;
        contentSize = innerBoundarySize;
        contentMaxOffset = innerBoundarySizeClamped - widgetSize;
    }

    return scrollController;
}

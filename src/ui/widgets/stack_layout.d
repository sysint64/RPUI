module ui.widgets.stack_layout;

import ui.widget;
import gapi;
import basic_types;
import math.linalg;
import std.math;


class StackLayout : Widget {
    @Field Orientation orientation = Orientation.vertical;

    this() {
        super();
        skipFocus = true;
    }

    this(Orientation orientation) {
        super();
        this.orientation = orientation;
        skipFocus = true;
    }

    override void addWidget(Widget widget) {
        assert(parent !is null, "Can't add widget to widget without parent!");
        Widget cell = new Widget();
        super.addWidget(cell);
        cell.addWidget(widget);
        cell.associatedWidget = widget;
        cell.skipFocus = true;
    }

    override void onProgress() {
        super.onProgress();
        updateAbsolutePosition();

        float lastPosition = 0;
	vec2 maxSize = vec2(0, 0);

        Widget widget = null;

        foreach (Widget cell; children) {
            widget = cell.firstWidget;

            if (orientation == Orientation.vertical) {
                cell.size.x = parent.innerSize.x;
                cell.size.y = widget.outerSize.y;

                cell.position.y = lastPosition;
                lastPosition += widget.size.y + widget.outerOffset.bottom;
            } else {
                cell.size.x = widget.outerSize.x;
                cell.size.y = parent.innerSize.y;

                cell.position.x = lastPosition;
                lastPosition += widget.size.x + widget.outerOffset.left;
            }

            maxSize = vec2(
                fmax(maxSize.x, widget.outerSize.x),
                fmax(maxSize.y, widget.outerSize.y),
            );

            cell.updateAbsolutePosition();
        }

        if (orientation == Orientation.vertical) {
            size.x = maxSize.x > parent.innerSize.x ? maxSize.x : parent.innerSize.x;
            size.y = lastPosition + widget.outerOffset.bottom;
        } else {
            size.x = lastPosition + widget.outerOffset.right;
            size.y = maxSize.y > parent.innerSize.y ? maxSize.y : parent.innerSize.y;
        }
    }
}

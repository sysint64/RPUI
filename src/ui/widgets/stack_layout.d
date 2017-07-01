module ui.widgets.stack_layout;

import ui.widget;
import gapi;
import basic_types;
import math.linalg;
import std.stdio;


private class Cell : Widget {
    this() {
        super();
        skipFocus = true;
    }
}


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
        Cell cell = new Cell();
        super.addWidget(cell);
        cell.addWidget(widget);
        cell.associatedWidget = widget;
    }

    Widget getFocusableWidget() {
        return children[0];
    }

    override void onProgress() {
        super.onProgress();
        updateAbsolutePosition();

        float lastLoc = 0;
	float maxWidth = 0;
	float maxHeight = 0;

        foreach (Widget cell; children) {
            Widget widget = null;
            widget = cell.firstWidget;

            if (orientation == Orientation.vertical) {
                cell.size.x = parent.size.x - parent.padding.right - parent.padding.left;
                cell.size.y = widget.size.y;

                cell.position.y = widget.margin.top + lastLoc;
                lastLoc += widget.size.y + widget.margin.top + widget.margin.bottom;

                const float widgetWidth = widget.locationAlign == Align.right ? 0 :
                    widget.position.x + widget.size.x + regionOffset.right;

                if (maxWidth < widgetWidth)
                    maxWidth = widgetWidth;
            } else {
                const float width = widget.size.x + widget.margin.left + widget.margin.right;

                cell.size.x = width;
                cell.size.y = parent.size.y - parent.padding.top - parent.padding.bottom;

                cell.position.x = lastLoc;
                lastLoc += width;

                const float widgetHeight = widget.locationVerticalAlign == VerticalAlign.bottom ?
                    0 : widget.position.y + widget.size.y + regionOffset.bottom;

                if (maxHeight < widgetHeight)
                    maxHeight = widgetHeight;
            }

            cell.updateAbsolutePosition();
        }

        if (orientation == Orientation.vertical) {
            size.x = maxWidth > parent.size.x ? maxWidth : parent.size.x;
            size.x -= regionOffset.right;
            size.y = lastLoc;
        } else {
            size.x = lastLoc;
            size.y = maxHeight > parent.size.y ? maxHeight : parent.size.y;
            size.y -= regionOffset.bottom;
        }
    }
}

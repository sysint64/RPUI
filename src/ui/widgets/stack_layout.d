module ui.widgets.stack_layout;

import ui.widget;
import gapi;
import basic_types;
import math.linalg;


class StackLayout : Widget {
    this() {
        super();
    }

    override void addWidget(Widget widget) {
        assert(parent !is null, "Can't add widget to widget without parent!");
        Widget cell = new Widget();
        super.addWidget(cell);
        cell.addWidget(widget);
    }

    override void render(Camera camera) {
        updateAbsolutePosition();

        float lastLoc = 0;
	float maxWidth = 0;
	float maxHeight = 0;

        foreach (uint index, Widget cell; children) {
            Widget widget = null;

            // TODO: get first item from children :/
            foreach (uint index, Widget childWidget; cell.children)
                widget = childWidget;

            if (orientation == Orientation.vertical) {
                cell.size.x = parent.size.x - parent.padding.right - parent.padding.left;
                cell.size.y = widget.size.y;

                cell.position.y = widget.margin.top + lastLoc;
                lastLoc += widget.size.y + widget.margin.top + widget.margin.bottom;

                const float widgetWidth = widget.locationAlign == Align.right ? 0 :
                    widget.position.x + widget.size.x + offsetSizeX();

                if (maxWidth < widgetWidth)
                    maxWidth = widgetWidth;
            } else {
                const float width = widget.size.x + widget.margin.left + widget.margin.right;

                cell.size.x = width;
                cell.size.y = parent.size.y - parent.padding.top - parent.padding.bottom;

                cell.position.x = lastLoc;
                lastLoc += width;

                const float widgetHeight = widget.locationVerticalAlign == VerticalAlign.bottom ?
                    0 : widget.position.y + widget.size.y + offsetSizeY();

                if (maxHeight < widgetHeight)
                    maxHeight = widgetHeight;
            }

            cell.updateAbsolutePosition();
            cell.render(camera);
        }

        if (orientation == Orientation.vertical) {
            size.x = maxWidth > parent.size.x ? maxWidth : parent.size.x;
            size.x -= offsetSizeX();
            size.y = lastLoc;
        } else {
            size.x = lastLoc;
            size.y = maxHeight > parent.size.y ? maxHeight : parent.size.y;
            size.y -= offsetSizeY();
        }

        size = vec2(1000, 1000);
    }

    @property Orientation orientation() { return p_orientation; }
    @property void orientation(in Orientation val) { p_orientation = val; }

private:
    Orientation p_orientation = Orientation.vertical;
}

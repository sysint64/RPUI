/**
 * Copyright: © 2017 RedGoosePaws
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 * Authors: Andrey Kabylin
 */

module rpui.widgets.stack_layout;

import rpui.widget;
import gapi;
import basic_types;
import math.linalg;
import std.math;

/**
 * Widget automatically placing children as in stack.
 */
class StackLayout : Widget {
    @Field Orientation orientation = Orientation.vertical;

    private vec2 maxSize = vec2(0, 0);

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

        vec2 lastPosition = vec2(0, 0);
        Widget widget = null;

        // TODO: move to `updateResize`
        foreach (Widget cell; children) {
            widget = cell.firstWidget;

            if (orientation == Orientation.vertical) {
                cell.widthType = SizeType.matchParent;
                cell.size.y = widget.outerSize.y;
                cell.position.y = lastPosition.y;
                cell.updateSize();
            } else {
                cell.size.x = widget.outerSize.x;
                cell.heightType = SizeType.matchParent;
                cell.position.x = lastPosition.x;
                cell.updateSize();
            }

            lastPosition += widget.size + widget.outerOffsetEnd;
            maxSize = vec2(
                fmax(maxSize.x, widget.outerSize.x),
                fmax(maxSize.y, widget.outerSize.y),
            );

            cell.updateAbsolutePosition();  // TODO: Maybe it's deprecated
        }

        updateSize();

        if (orientation == Orientation.vertical) {
            size.y = lastPosition.y + widget.outerOffset.bottom;
        } else {
            size.x = lastPosition.x + widget.outerOffset.right;
        }
    }

    override void updateSize() {
        super.updateSize();

        if (orientation == Orientation.vertical && widthType == SizeType.wrapContent) {
            size.x = maxSize.x > parent.innerSize.x ? maxSize.x : parent.innerSize.x;
        } else if (widthType == SizeType.wrapContent) {
            size.y = maxSize.y > parent.innerSize.y ? maxSize.y : parent.innerSize.y;
        }
    }
}

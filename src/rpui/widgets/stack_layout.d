/**
 * Copyright: © 2017 Andrey Kabylin
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 */

module rpui.widgets.stack_layout;

import rpui.widget;
import rpui.widgets.stack_locator;

import gapi;
import basic_types;
import math.linalg;
import std.math;

/**
 * Widget automatically placing children as in stack.
 */
class StackLayout : Widget {
    @Field
    @property Orientation orientation() { return stackLocator.orientation; }
    @property void orientation(in Orientation val) { stackLocator.orientation = val; }

    private vec2 maxSize = vec2(0, 0);
    private vec2 lastWidgetPosition = vec2(0, 0);
    private Widget lastWidget = null;
    private StackLocator stackLocator;

    this(in string style = "StackLayout") {
        super(style);

        skipFocus = true;
        stackLocator.attach(this);
    }

    this(Orientation orientation) {
        super();
        this.orientation = orientation;
        skipFocus = true;
        stackLocator.attach(this);
    }

    override void progress() {
        super.progress();

        locator.updateAbsolutePosition();
        locator.updateRegionAlign();

        updateSize();
    }

    override void updateSize() {
        super.updateSize();

        stackLocator.updateWidgetsPosition();
        stackLocator.updateSize();
    }
}

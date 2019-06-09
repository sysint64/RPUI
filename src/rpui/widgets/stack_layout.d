module rpui.widgets.stack_layout;

import rpui.events;
import rpui.widget;
import rpui.widgets.stack_locator;
import rpui.primitives;
import rpui.math;

class StackLayout : Widget {
    @field
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

    override void onProgress(in ProgressEvent event) {
        super.onProgress(event);

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

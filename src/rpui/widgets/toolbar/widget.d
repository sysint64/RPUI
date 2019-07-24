module rpui.widgets.toolbar.widget;

import rpui.primitives;
import rpui.widgets.toolbar.renderer;
import rpui.widget;

final class Toolbar : Widget {
    this(in string style = "Toolbar") {
        super(style);

        this.renderer = new ToolbarRenderer();
        this.regionAlign = RegionAlign.top;
    }
}

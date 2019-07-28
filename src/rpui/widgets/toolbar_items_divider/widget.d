module rpui.widgets.toolbar_items_divider.widget;

import rpui.primitives;
import rpui.widgets.toolbar_items_divider.renderer;
import rpui.widget;

final class ToolbarItemsDivider : Widget {
    this(in string style = "ToolbarItemsDivider") {
        super(style);
        this.renderer = new ToolbarItemsDividerRenderer();
    }
}

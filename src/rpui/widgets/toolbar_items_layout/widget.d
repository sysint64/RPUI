module rpui.widgets.toolbar_items_layout.widget;

import rpui.primitives;
import rpui.events;
import rpui.widget;
import rpui.widgets.stack_layout.widget;

final class ToolbarItemsLayout : StackLayout {
    this(in string style = "ToolbarItemsLayout") {
        super(style);
        this.orientation = Orientation.horizontal;
    }
}

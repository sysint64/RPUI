module rpui.widgets.list_menu_items_divider.widget;

import rpui.primitives;
import rpui.widgets.list_menu_items_divider.renderer;
import rpui.widget;

final class ListMenuItemsDivider : Widget {
    this(in string style = "ListMenuItemsDivider") {
        super(style);
        this.renderer = new ListMenuItemsDividerRenderer();
        this.widthType = SizeType.matchParent;
    }
}

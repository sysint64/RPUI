module rpui.widgets.main_menu_item.widget;

import rpui.widgets.drop_list_menu.widget;

final class MainMenuItem : DropListMenu {
    this(in string style = "MainMenuItem", in string iconsGroup = "icons") {
        super(style, iconsGroup);
        skipFocus = true;
    }
}

/**
 * Copyright: © 2018 Andrey Kabylin
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 */

module rpui.widgets.drop_list_menu;

import gapi;
import basic_types;

import rpui.widgets.button;
import rpui.widgets.list_menu;

final class DropListMenu : Button {
    @property ListMenu menu() {
        return cast(ListMenu) children.front;
    }

    this(in string style = "DropListMenu", in string iconsGroup = "icons") {
        super(style, iconsGroup);
        textAlign = Align.left;
    }

    protected override void onPostCreate() {
        super.onPostCreate();

        menu.visible = false;
        manager.moveWidgetToFront(menu);
    }
}

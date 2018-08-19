/**
 * Copyright: © 2018 Andrey Kabylin
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 */

module rpui.widgets.drop_list_menu;

import gapi;
import basic_types;
import math.linalg;

import rpui.widgets.button;
import rpui.widgets.list_menu;
import rpui.widget_events;
import rpui.events;

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

    override void onMouseDown(in MouseDownEvent event) {
        super.onMouseDown(event);

        if (isEnter)
            toggleMenu();
    }

    void toggleMenu() {
        if (!menu.visible) {
            dropMenu();
        } else {
            hideMenu();
        }
    }

    void dropMenu() {
        menu.position = absolutePosition + vec2(0, size.y) + menu.popupOffset;
        menu.visible = true;
    }

    void hideMenu() {
        menu.visible = false;
    }

    override void onBlur(in BlurEvent event) {
        super.onBlur(event);
        hideMenu();
    }
}

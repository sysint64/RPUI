/**
 * Copyright: © 2018 Andrey Kabylin
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 */

module rpui.widgets.drop_list_menu;

import gapi;
import basic_types;
import basic_rpdl_extensions;
import math.linalg;

import rpui.widgets.button;
import rpui.widgets.list_menu;
import rpui.widget_events;
import rpui.events;
import rpui.widgets.drop_menu_delegate;

final class DropListMenu : Button {
    @property ListMenu menu() {
        return cast(ListMenu) children.front;
    }

    private bool isInVisibilityArea = false;
    private bool isInMenuArea = false;
    private DropMenuDelegate dropMenuDelegate;

    this(in string style = "DropListMenu", in string iconsGroup = "icons") {
        super(style, iconsGroup);
        textAlign = Align.left;
    }

    protected override void onPostCreate() {
        super.onPostCreate();

        menu.visible = false;
        menu.focusable = false;
        manager.moveWidgetToFront(menu);

        dropMenuDelegate = new DropMenuDelegate(menu, this);
    }

    override void progress() {
        super.progress();
        dropMenuDelegate.progress(vec2(0, size.y));
    }

    override void onMouseDown(in MouseDownEvent event) {
        super.onMouseDown(event);

        if (isEnter) {
            toggleMenu();
            focus();
        }
    }

    override void onBlur(in BlurEvent event) {
        super.onBlur(event);

        if (!isInMenuArea) {
            hideMenu();
        }
    }

    void toggleMenu() {
        dropMenuDelegate.toggleMenu(vec2(0, size.y));
    }

    void dropMenu() {
        dropMenuDelegate.dropMenu(vec2(0, size.y));
    }

    void hideMenu() {
        dropMenuDelegate.hideMenu();
    }
}
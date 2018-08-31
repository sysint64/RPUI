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

    private bool isInVisibilityArea = false;
    private bool isInMenuArea = false;

    this(in string style = "DropListMenu", in string iconsGroup = "icons") {
        super(style, iconsGroup);
        textAlign = Align.left;
    }

    protected override void onPostCreate() {
        super.onPostCreate();

        menu.visible = false;
        manager.moveWidgetToFront(menu);
    }

    override void progress() {
        super.progress();

        const pos = absolutePosition - vec2(20, 0);
        const extend = vec2(40, 50);

        const extraStartArea = vec2(menu.popupExtraPadding.left, menu.popupExtraPadding.top);
        const extraEndArea = vec2(menu.popupExtraPadding.right, menu.popupExtraPadding.bottom);

        const visibileArea = Rect(pos, vec2(0, size.y) + menu.size + extend);
        const menuArea = Rect(
            menu.absolutePosition + extraStartArea,
            menu.size - extraStartArea - extraEndArea
        );

        isInVisibilityArea = pointInRect(app.mousePos, visibileArea);
        isInMenuArea = pointInRect(app.mousePos, menuArea);

        if (!isInVisibilityArea) {
            hideMenu();
        }
    }

    override void onMouseDown(in MouseDownEvent event) {
        super.onMouseDown(event);

        if (isEnter) {
            toggleMenu();
            focus();
        }
        else if (!isInMenuArea) {
            hideMenu();
        }
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
}

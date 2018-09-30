/**
 * Copyright: © 2018 Andrey Kabylin
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 */

module rpui.widgets.list_menu_item;

import gapi;
import time;
import basic_types;
import math.linalg;

import rpui.widgets.button;
import rpui.widgets.list_menu;
import rpui.render_objects;
import rpui.widget_events;
import rpui.widgets.drop_menu_delegate;

interface MenuActions {
    void hideMenu();

    MenuActions parentActions();
}

final class ListMenuItem : Button, MenuActions {
    @Field string shortcut = "";

    private ListMenu parentMenu = null;
    private ListMenu menu = null;
    private BaseRenderObject submenuArrowRenderObject;
    private vec2 submenuArrowOffset;
    private DropMenuDelegate dropMenuDelegate;
    private Interval submenuDisplayTimeout;

    this(in string style = "ListItem", in string iconsGroup = "icons") {
        super(style, iconsGroup);

        textAlign = Align.left;
        widthType = SizeType.matchParent;
        focusable = false;
    }

    protected override void onCreate() {
        super.onCreate();

        const states = ["Leave", "Enter", "Click"];
        submenuArrowRenderObject = renderFactory.createQuad(style, states, "submenuArrow");

        with (manager.theme.tree) {
            submenuArrowOffset = data.getVec2f(style ~ ".submenuArrowOffset");
        }
    }

    protected override void onPostCreate() {
        super.onPostCreate();

        if (menu !is null)
            return;

        // Because item places in wrapper called Cell.
        parentMenu = cast(ListMenu) parent.parent;
        assert(parentMenu !is null);

        events.subscribe!ClickEvent(&onClick);

        if (children.empty)
            return;

        menu = cast(ListMenu)(children.front);

        if (menu is null)
            return;

        menu.visible = false;
        menu.focusable = false;
        manager.moveWidgetToFront(menu);

        dropMenuDelegate.attach(menu, this);

        submenuDisplayTimeout = createTimeout(menu.displayDelay, delegate() {
            if (isEnter) {
                dropMenuDelegate.dropMenu(vec2(size.x, 0) + menu.rightPopupOffset);
            }
        });
    }

    override void progress() {
        super.progress();
        submenuDisplayTimeout.onProgress(app.deltaTime);

        if (isEnter) {
            parentMenu.hideAllSubMenusExpect(this);
        }

        if (isEnter && !submenuDisplayTimeout.isStarted()) {
            submenuDisplayTimeout.start();
        }

        if (dropMenuDelegate.isAttached()) {
            dropMenuDelegate.progress(vec2(size.x, 0) + menu.rightPopupOffset);
            overrideIsEnter = dropMenuDelegate.isInVisibilityArea && menu.visible;
        }
    }

    override void render(Camera camera) {
        super.render(camera);

        if (menu !is null) {
            const arrowPosition = absolutePosition + vec2(size.x - submenuArrowRenderObject.scaling.x, 0);
            renderer.renderQuad(submenuArrowRenderObject, state, arrowPosition + submenuArrowOffset);
        }
    }

    private void onClick() {
        if (menu is null)
            hideRootMenu();

        if (dropMenuDelegate.isAttached()) {
            dropMenuDelegate.dropMenu(vec2(size.x, 0) + menu.rightPopupOffset);
        }
    }

    override void focus() {
        /* Ignore */
    }

    override void hideMenu() {
        if (dropMenuDelegate.isAttached()) {
            dropMenuDelegate.hideMenu();
        }
    }

    private void hideRootMenu() {
        MenuActions currentMenuActions = this;
        MenuActions parentMenuActions = parentActions();

        while (parentMenuActions !is null) {
            currentMenuActions = parentMenuActions;
            parentMenuActions = parentMenuActions.parentActions();
        }

        currentMenuActions.hideMenu();
    }

    override MenuActions parentActions() {
        auto actions = cast(MenuActions) parentMenu.owner;
        return actions;
    }
}

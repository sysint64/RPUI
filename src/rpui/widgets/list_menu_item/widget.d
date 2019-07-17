module rpui.widgets.list_menu_item.widget;

import rpui.events;
import rpui.widget_events;
import rpui.input;
import rpui.math;
import rpui.primitives;
import rpui.widget;
import rpui.widgets.button.widget;
import rpui.widgets.list_menu.widget;
import rpui.widgets.list_menu_item.renderer;
import rpui.widgets.drop_list_menu.drop_menu_delegate;

interface MenuActions {
    void hideMenu();

    MenuActions parentActions();
}

class ListMenuItem : Button, MenuActions {
    @field string shortcut = "";

    private ListMenu parentMenu = null;
    package ListMenu menu = null;
    private DropMenuDelegate dropMenuDelegate;

    this(in string style = "ListMenuItem") {
        super(style);

        this.renderer = new ListMenuItemRenderer();
        this.textAlign = Align.left;
        this.widthType = SizeType.matchParent;
        this.focusable = false;
    }

    protected override void onPostCreate() {
        super.onPostCreate();

        if (menu !is null)
            return;

        // Because item places in wrapper called Cell.
        parentMenu = cast(ListMenu) parent.parent;
        assert(parentMenu !is null);

        if (parentMenu.isPopup) {
            uselessIconArea = 1;
        }

        events.subscribe!ClickEvent(&onClick);
        attachShortcut();

        if (children.empty)
            return;

        menu = cast(ListMenu)(children.front);

        if (menu is null)
            return;

        menu.isVisible = false;
        menu.focusable = false;
        view.moveWidgetToFront(menu);

        dropMenuDelegate.attach(menu, this);

        // submenuDisplayTimeout = createTimeout(menu.displayDelay, delegate() {
            if (isEnter) {
                dropMenuDelegate.dropMenu(vec2(size.x, 0) + menu.measure.rightPopupOffset);
            }
        // });
    }

    void attachShortcut() {
        if (shortcut.length == 0)
            return;

        if (shortcut[0] == '@') {
            const shortcutPath = shortcut[1 .. $];
            view.shortcuts.attachByPath(shortcutPath, () => events.notify(ClickEvent()));
        } else {
            view.shortcuts.attach(shortcut, () => events.notify(ClickEvent()));
        }
    }

    override void onProgress(in ProgressEvent event) {
        super.onProgress(event);

        // submenuDisplayTimeout.onProgress(app.deltaTime);

        if (isEnter) {
            parentMenu.hideAllSubMenusExcept(this);
        }

        // if (isEnter && !submenuDisplayTimeout.isStarted()) {
            // submenuDisplayTimeout.start();
        // }

        if (dropMenuDelegate.isAttached()) {
            dropMenuDelegate.onProgress(vec2(size.x, 0) + menu.measure.rightPopupOffset);
            overrideIsEnter = dropMenuDelegate.isInVisibilityArea && menu.isVisible;
        }
    }

    private void onClick() {
        if (menu is null)
            hideRootMenu();

        if (dropMenuDelegate.isAttached()) {
            dropMenuDelegate.dropMenu(vec2(size.x, 0) + menu.measure.rightPopupOffset);
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

module rpui.widgets.drop_list_menu.widget;

import rpui.events;
import rpui.widget_events;
import rpui.input;
import rpui.math;
import rpui.primitives;
import rpui.widget;
import rpui.widgets.list_menu.widget;
import rpui.widgets.list_menu_item.widget;
import rpui.widgets.button.widget;
import rpui.widgets.drop_list_menu.drop_menu_delegate;

class DropListMenu : Button, MenuActions {
    private bool isInVisibilityArea = false;
    private bool isInMenuArea = false;
    private DropMenuDelegate dropMenuDelegate;
    private ListMenu menu = null;

    this(in string style = "DropListMenu", in string iconsGroup = "icons") {
        super(style, iconsGroup);
        textAlign = Align.left;
    }

    protected override void onPostCreate() {
        super.onPostCreate();

        if (menu !is null)
            return;

        menu = cast(ListMenu) children.front;
        assert(menu !is null);

        menu.visible = false;
        menu.focusable = false;
        view.moveWidgetToFront(menu);

        dropMenuDelegate.attach(menu, this);
    }

    override void onProgress(in ProgressEvent event) {
        super.onProgress(event);
        dropMenuDelegate.onProgress(vec2(0, size.y));
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

    override void hideMenu() {
        dropMenuDelegate.hideMenu();
    }

    override MenuActions parentActions() {
        return null;
    }
}

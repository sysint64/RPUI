module rpui.widgets.drop_menu_delegate;

import basic_types;
import math.linalg;

import application;
import rpui.widget;
import rpui.widgets.list_menu;

package struct DropMenuDelegate {
    private ListMenu menu;
    private Widget widget;
    private Application app;

    bool isInVisibilityArea = false;
    bool isInMenuArea = false;
    private bool isAttached_ = false;

    bool isAttached() const {
        return isAttached_;
    }

    void attach(ListMenu menu, Widget widget) {
        this.menu = menu;
        this.widget = widget;
        app = Application.getInstance();
        isAttached_ = true;
    }

    void progress(in vec2 dropOffset) {
        const visibleBorderStart = vec2(menu.extraMenuVisibleBorder.left, menu.extraMenuVisibleBorder.top);
        const visibleBorderEnd = vec2(menu.extraMenuVisibleBorder.right, menu.extraMenuVisibleBorder.bottom);

        const extraStartArea = vec2(menu.popupExtraPadding.left, menu.popupExtraPadding.top);
        const extraEndArea = vec2(menu.popupExtraPadding.right, menu.popupExtraPadding.bottom);

        const visibileArea = Rect(
            widget.absolutePosition - visibleBorderStart,
            dropOffset + menu.size + visibleBorderEnd + visibleBorderStart
        );

        const menuArea = Rect(
            menu.absolutePosition + extraStartArea,
            menu.size - extraStartArea - extraEndArea
        );

        bool oneOfItemIsEnter = false;

        foreach (Widget child; menu.children) {
            const row = child.associatedWidget;
            oneOfItemIsEnter = oneOfItemIsEnter || row.isEnter || row.overrideIsEnter;
        }

        isInVisibilityArea = pointInRect(app.mousePos, visibileArea) || oneOfItemIsEnter;
        isInMenuArea = pointInRect(app.mousePos, menuArea);

        if (!isInVisibilityArea) {
            hideMenu();
        }
    }

    void toggleMenu(in vec2 dropOffset) {
        if (!menu.visible) {
            dropMenu(dropOffset);
        } else {
            hideMenu();
        }
    }

    void dropMenu(in vec2 dropOffset) {
        menu.position = widget.absolutePosition + dropOffset + menu.downPopupOffset;
        menu.visible = true;
    }

    void hideMenu() {
        menu.visible = false;
        menu.hideAllSubMenus();
    }
}

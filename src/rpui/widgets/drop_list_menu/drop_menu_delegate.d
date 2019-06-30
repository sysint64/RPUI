module rpui.widgets.drop_list_menu.drop_menu_delegate;

import rpui.primitives;
import rpui.math;
import rpui.widget;
import rpui.widgets.list_menu.widget;

struct DropMenuDelegate {
    private ListMenu menu;
    private Widget widget;

    bool isInVisibilityArea = false;
    bool isInMenuArea = false;
    private bool isAttached_ = false;

    bool isAttached() const {
        return isAttached_;
    }

    void attach(ListMenu menu, Widget widget) {
        this.menu = menu;
        this.widget = widget;
        isAttached_ = true;
    }

    void onProgress(in vec2 dropOffset) {
        const visibleBorderStart = vec2(
            menu.measure.extraMenuVisibleBorder.left,
            menu.measure.extraMenuVisibleBorder.top
        );
        const visibleBorderEnd = vec2(
            menu.measure.extraMenuVisibleBorder.right,
            menu.measure.extraMenuVisibleBorder.bottom
        );

        const extraStartArea = vec2(menu.measure.popupExtraPadding.left, menu.measure.popupExtraPadding.top);
        const extraEndArea = vec2(menu.measure.popupExtraPadding.right, menu.measure.popupExtraPadding.bottom);

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

        isInVisibilityArea = pointInRect(menu.view.mousePos, visibileArea) || oneOfItemIsEnter;
        isInMenuArea = pointInRect(menu.view.mousePos, menuArea);

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
        menu.position = widget.absolutePosition + dropOffset + menu.measure.downPopupOffset;
        menu.visible = true;
    }

    void hideMenu() {
        menu.visible = false;
        menu.hideAllSubMenus();
    }
}

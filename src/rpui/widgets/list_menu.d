/**
 * Copyright: © 2018 Andrey Kabylin
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 */

module rpui.widgets.list_menu;

import gapi;
import basic_types;
import basic_rpdl_extensions;
import math.linalg;

import rpui.widget;
import rpui.render_objects;
import rpui.widgets.stack_layout;
import rpui.widgets.list_menu_item;

class ListMenu : StackLayout {
    @Field bool transparent = false;
    @Field bool checkList = false;
    @Field bool isPopup = true;
    @Field string listItemStyle = "ListItem";

    package float displayDelay = 0f;
    private BaseRenderObject[string] backgroundParts;
    package FrameRect popupExtraPadding;
    package vec2 downPopupOffset;
    package vec2 rightPopupOffset;
    package FrameRect extraMenuVisibleBorder;

    this(in string style = "ListMenu") {
        super(style);

        widthType = SizeType.value;
        heightType = SizeType.wrapContent;
    }

    override void progress() {
        super.progress();

        locator.updateAbsolutePosition();
        locator.updateLocationAlign();
        locator.updateVerticalLocationAlign();
        locator.updateRegionAlign();

        updateSize();

        if (isPopup)
            extraInnerOffset = popupExtraPadding;
    }

    override void render(Camera camera) {
        if (isPopup) {
            // Background
            renderer.renderBlock(backgroundParts, absolutePosition, size);
        }

        super.render(camera);
    }

    void hideAllSubMenus() {
        foreach (Widget widget; children) {
            const row = widget.associatedWidget;

            if (auto item = cast(MenuActions) row) {
                item.hideMenu();
            }
        }
    }

    package void hideAllSubMenusExpect(Widget menuItem) {
        foreach (Widget widget; children) {
            const row = widget.associatedWidget;

            if (row == menuItem)
                continue;

            if (auto item = cast(MenuActions) row) {
                item.hideMenu();
            }
        }
    }

    protected override void onCreate() {
        super.onCreate();

        const parts = ["Top", "Middle", "Bottom"];
        const keys = ["left", "center", "right"];

        foreach (string key; keys) {
            renderFactory.createQuad(backgroundParts, style, parts, key);
        }

        with (manager.theme.tree) {
            popupExtraPadding = data.getFrameRect(style ~ ".popupExtraPadding");
            rightPopupOffset = data.getVec2f(style ~ ".rightPopupOffset");
            downPopupOffset = data.getVec2f(style ~ ".downPopupOffset");
            extraMenuVisibleBorder = data.getFrameRect(style ~ ".extraMenuVisibleBorder");
            displayDelay = data.getNumber(style ~ ".displayDelay.0");
        }
    }
}

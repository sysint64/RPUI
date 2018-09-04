/**
 * Copyright: © 2018 Andrey Kabylin
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 */

module rpui.widgets.list_menu_item;

import gapi;
import basic_types;
import math.linalg;

import rpui.widgets.button;
import rpui.widgets.list_menu;
import rpui.render_objects;

final class ListMenuItem : Button {
    @Field string shortcut = "";

    private ListMenu menu = null;
    private BaseRenderObject submenuArrowRenderObject;
    private vec2 submenuArrowOffset;

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

        if (children.empty)
            return;

        menu = cast(ListMenu)(children.front);

        if (menu is null)
            return;

        menu.visible = false;
        menu.focusable = false;
        manager.moveWidgetToFront(menu);
    }

    this(in string style = "ListItem", in string iconsGroup = "icons") {
        super(style, iconsGroup);
        textAlign = Align.left;
        widthType = SizeType.matchParent;
        focusable = false;
    }

    override void render(Camera camera) {
        super.render(camera);

        if (menu !is null) {
            const arrowPosition = absolutePosition + vec2(size.x - submenuArrowRenderObject.scaling.x, 0);
            renderer.renderQuad(submenuArrowRenderObject, state, arrowPosition + submenuArrowOffset);
        }
    }
}

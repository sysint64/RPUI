/**
 * Copyright: © 2018 Andrey Kabylin
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 */

module rpui.widgets.list_menu_item;

import gapi;
import basic_types;

import rpui.widgets.button;

final class ListMenuItem : Button {
    @Field string shortcut = "";

    this(in string style = "ListItem", in string iconsGroup = "icons") {
        super(style, iconsGroup);
        textAlign = Align.left;
        widthType = SizeType.matchParent;
    }

    override void render(Camera camera) {
        super.render(camera);
    }
}

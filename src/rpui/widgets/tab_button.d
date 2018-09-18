/**
 * Copyright: © 2018 Andrey Kabylin
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 */

module rpui.widgets.tab_button;

import rpui.widget;
import rpui.widgets.button;

final class TabButton : Button {
    @Field bool checked = false;

    this(in string style = "TabButton", in string iconsGroup = "icons") {
        super(style, iconsGroup);

        // widthType = SizeType.wrapContent;
        focusable = false;
    }

    override void progress() {
        super.progress();
        isClick = checked;
    }
}

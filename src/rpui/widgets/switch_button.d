/**
 * Copyright: © 2017 Andrey Kabylin
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 */

module rpui.widgets.switch_button;

import rpui.widgets.button;
import rpui.events;

final class SwitchButton : Button {
    @Field bool checked = false;

    this(in string style = "SwitchButton", in string iconsGroup = "icons") {
        super(style, iconsGroup);
    }

    override void progress() {
        super.progress();
        isClick = checked;
    }

    override void onMouseDown(in MouseDownEvent event) {
        super.onMouseDown(event);

        if (!isEnter)
            return;

        checked = !checked;
    }

    override void reset() {
        checked = false;
    }
}

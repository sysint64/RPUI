/**
 * Copyright: © 2017 Andrey Kabylin
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 */

module rpui.widgets.check_button;

import rpui.widgets.button;
import rpui.events;

final class CheckButton : Button {
    @Field bool checked = false;

    this(in string style = "CheckButton", in string iconsGroup = "icons") {
        super(style, iconsGroup);
        focusable = false;
    }

    override void progress() {
        super.progress();
        isClick = checked;
    }

    override void onMouseDown(in MouseDownEvent event) {
        super.onMouseDown(event);

        if (!isEnter)
            return;

        getNonDecoratorParent().resetChildren();
        checked = true;
    }

    override void reset() {
        checked = false;
    }
}

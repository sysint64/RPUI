module rpui.widgets.check_button.widget;

import rpui.widgets.button.widget;
import rpui.events;

final class CheckButton : Button {
    @field bool checked = false;

    this(in string style = "CheckButton", in string iconsGroup = "icons") {
        super(style, iconsGroup);
        focusable = false;
    }

    override void onProgress(in ProgressEvent event) {
        super.onProgress(event);
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

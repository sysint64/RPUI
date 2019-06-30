module rpui.widgets.switch_button.widget;

import rpui.widgets.button.widget;
import rpui.events;

final class SwitchButton : Button {
    @field bool checked = false;

    this(in string style = "SwitchButton", in string iconsGroup = "icons") {
        super(style, iconsGroup);
    }

    override void onProgress(in ProgressEvent event) {
        super.onProgress(event);
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

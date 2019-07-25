module rpui.widgets.toolbar_tab_button.widget;

import rpui.widget;
import rpui.events;
import rpui.primitives;
import rpui.widgets.button.widget;
import rpui.widgets.tab_button.widget;

final class ToolbarTabButton : TabButton {
    this(in string style = "ToolbarTabButton", in string iconsGroup = "icons") {
        super(style, iconsGroup);
        verticalLocationAlign = VerticalAlign.bottom;
    }

    override void onPostCreate() {
        super.onPostCreate();
    }
}

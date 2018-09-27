/**
 * Copyright: © 2017 Andrey Kabylin
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 */

module rpui.widgets.tab_layout;

import rpui.widget;
import rpui.widgets.stack_layout;
import rpui.widgets.tab_button;

final class TabLayout : StackLayout {
    package void uncheckAllTabs() {
        foreach (Widget widget; children) {
            const row = widget.associatedWidget;
            assert(cast(TabButton) row !is null);
            (cast(TabButton) row).checked = false;
        }
    }
}

module rpui.widgets.toolbar_tab_layout.widget;

import rpui.events;
import rpui.widget;
import rpui.widgets.tab_layout.widget;
import rpui.widgets.toolbar_tab_layout.renderer;

final class ToolbarTabLayout : TabLayout {
    this(in string style = "ToolbarTabLayout") {
        super(style);
        renderer = new ToolbarTabLayoutRenderer();
    }
}

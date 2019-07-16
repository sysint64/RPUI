module rpui.widgets.tab_layout.widget;

import rpui.events;
import rpui.widget;
import rpui.widgets.stack_layout.widget;
import rpui.widgets.tab_layout.renderer;

final class TabLayout : StackLayout {
    @field bool showBorder = true;

    this(in string style = "TabLayout") {
        super(style);
        renderer = new TabLayoutRenderer();
        widthType = SizeType.matchParent;
    }

    override void onRender() {
        renderer.onRender();
    }
}

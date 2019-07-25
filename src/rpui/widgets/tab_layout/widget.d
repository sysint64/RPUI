module rpui.widgets.tab_layout.widget;

import rpui.primitives;
import rpui.events;
import rpui.widget;
import rpui.widgets.stack_layout.widget;
import rpui.widgets.tab_layout.renderer;

class TabLayout : StackLayout {
    @field bool showBorder = true;

    this(in string style = "TabLayout") {
        super(style);
        renderer = new TabLayoutRenderer();
        widthType = SizeType.matchParent;
        orientation = Orientation.horizontal;
    }

    override void onRender() {
        renderer.onRender();
    }
}

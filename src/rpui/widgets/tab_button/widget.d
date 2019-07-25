module rpui.widgets.tab_button.widget;

import rpui.widget;
import rpui.events;
import rpui.primitives;
import rpui.widgets.button.widget;
import rpui.widgets.tab_button.renderer;
import rpui.widgets.tab_layout.widget;

class TabButton : Button {
    @field bool checked = false;
    @field bool hideCaptionWhenUnchecked = false;

    private TabLayout parentTabLayout = null;

    this(in string style = "TabButton", in string iconsGroup = "icons") {
        super(style, iconsGroup);

        renderer = new TabButtonRenderer();
        widthType = SizeType.wrapContent;
        focusable = false;
    }

    protected override void onPostCreate() {
        super.onPostCreate();

        // Because tab places in wrapper called Cell.
        parentTabLayout = cast(TabLayout) parent.parent;
        assert(parentTabLayout !is null);
    }

    override void onProgress(in ProgressEvent event) {
        super.onProgress(event);
        isClick = checked;
    }

    override void onMouseDown(in MouseDownEvent event) {
        super.onMouseDown(event);

        if (!isEnter)
            return;

        parentTabLayout.resetChildren();
        checked = true;
        parentTabLayout.parent.updateAll();
    }

    override void reset() {
        checked = false;
    }
}

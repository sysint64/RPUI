module rpui.widgets.toolbar_item.widget;

import rpui.primitives;
import rpui.widget;
import rpui.events;
import rpui.widgets.toolbar_item.renderer;

final class ToolbarItem : Widget {
    @field bool isChecked = false;
    @field string icon;
    @field utf32string caption = "Button";
    @field string iconsGroup = "main_toolbar_icons";

    this(in string style = "ToolbarItem") {
        super(style);
        focusable = false;
        renderer = new ToolbarItemRenderer();
    }

    override void onCreate() {
        super.onCreate();
        loadMeasure();
    }

    private void loadMeasure() {
        with (view.theme.tree) {
            size = data.getVec2f(style ~ ".size");
        }
    }

    override void onProgress(in ProgressEvent event) {
        super.onProgress(event);
        isClick = isChecked;
    }

    override void onMouseDown(in MouseDownEvent event) {
        super.onMouseDown(event);

        if (!isEnter)
            return;

        isChecked = !isChecked;
    }

    override void reset() {
        isChecked = false;
    }
}

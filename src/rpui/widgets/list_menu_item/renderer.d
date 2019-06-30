module rpui.widgets.list_menu_item.renderer;

import rpui.theme;
import rpui.events;
import rpui.widget;
import rpui.widgets.button.renderer;
import rpui.widgets.list_menu_item;
import rpui.render.components;
import rpui.render.components_factory;
import rpui.render.renderer;
import rpui.render.transforms;

final class ListMenuItemRenderer : ButtonRenderer {
    private ListMenuItem widget;
    private Theme theme;

    override void onCreate(Widget widget) {
        super.onCreate(widget);

        this.theme = widget.view.theme;
        this.widget = cast(ListMenuItem) widget;
    }

    override void onRender() {
        super.onRender();
    }

    override void onProgress(in ProgressEvent event) {
        super.onProgress(event);
    }
}

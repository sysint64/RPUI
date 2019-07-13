module rpui.widgets.list_menu.renderer;

import rpui.theme;
import rpui.events;
import rpui.widget;
import rpui.widgets.list_menu.widget;
import rpui.render.components;
import rpui.render.components_factory;
import rpui.render.renderer;
import rpui.render.transforms;

final class ListMenuRenderer : Renderer {
    private ListMenu widget;
    private Theme theme;

    private Block background;
    private BlockTransforms backgroundTransforms;

    override void onCreate(Widget widget, in string style) {
        this.theme = widget.view.theme;
        this.widget = cast(ListMenu) widget;
        this.background = createBlockFromRdpl(theme, style);
    }

    override void onRender() {
        if (widget.isPopup) {
            renderBlock(theme, background, backgroundTransforms);
        }
    }

    override void onProgress(in ProgressEvent event) {
        backgroundTransforms = updateBlockTransforms(
            background.widths,
            background.heights,
            widget.view.cameraView,
            widget.absolutePosition,
            widget.size
        );
    }
}

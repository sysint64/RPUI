module rpui.widgets.list_menu_item.renderer;

import rpui.theme;
import rpui.events;
import rpui.widget;
import rpui.math;
import rpui.widgets.button.renderer;
import rpui.widgets.list_menu_item.widget;
import rpui.render.components;
import rpui.render.components_factory;
import rpui.render.renderer;
import rpui.render.transforms;

final class ListMenuItemRenderer : ButtonRenderer {
    private ListMenuItem widget;
    private Theme theme;

    private vec2 submenuArrowOffset;
    private StatefulTexAtlasTextureQuad arrow;
    private QuadTransforms arrowTransforms;

    override void onCreate(Widget widget, in string style) {
        super.onCreate(widget, style);

        this.theme = widget.view.theme;
        this.widget = cast(ListMenuItem) widget;

        arrow = createStatefulTexAtlasTextureQuadFromRdpl(theme, style, "submenuArrow");
        submenuArrowOffset = theme.tree.data.getVec2f(style ~ ".submenuArrowOffset");
    }

    override void onRender() {
        super.onRender();

        if (widget.menu is null)
            return;

        renderTexAtlasQuad(theme, arrow, arrowTransforms);
    }

    override void onProgress(in ProgressEvent event) {
        super.onProgress(event);

        if (widget.menu is null)
            return;

        const arrowSize = arrow.currentTexCoords.originalTexCoords.size;
        const arrowPosition = widget.absolutePosition + vec2(widget.size.x - arrowSize.x, 0);

        arrow.state = widget.state;
        arrowTransforms = updateQuadTransforms(
            widget.view.cameraView,
            arrowPosition,
            arrowSize
        );
    }
}

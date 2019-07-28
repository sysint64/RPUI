module rpui.widgets.toolbar_items_divider.renderer;

import rpui.math;
import rpui.theme;
import rpui.events;
import rpui.widget;
import rpui.widgets.toolbar_items_divider.widget;
import rpui.render.components;
import rpui.render.components_factory;
import rpui.render.renderer;
import rpui.render.transforms;

final class ToolbarItemsDividerRenderer : Renderer {
    private ToolbarItemsDivider widget;
    private Theme theme;

    private vec2 dividerOffset;
    private TexAtlasTextureQuad divider;
    private QuadTransforms dividerTransforms;

    override void onCreate(Widget widget, in string style) {
        this.theme = widget.view.theme;
        this.widget = cast(ToolbarItemsDivider) widget;
        this.divider = createTexAtlasTextureQuadFromRdpl(theme, style, "divider");
        this.widget.size.x = this.theme.tree.data.getNumber(style ~ ".width.0");
        this.dividerOffset = this.theme.tree.data.getVec2f(style ~ ".dividerOffset");
    }

    override void onRender() {
        renderTexAtlasQuad(theme, divider, dividerTransforms);
    }

    override void onProgress(in ProgressEvent event) {
        dividerTransforms = updateQuadTransforms(
            widget.view.cameraView(),
            widget.absolutePosition + dividerOffset,
            divider.texCoords.originalTexCoords.size
        );
    }
}

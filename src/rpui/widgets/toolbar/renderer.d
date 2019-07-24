module rpui.widgets.toolbar.renderer;

import rpui.math;
import rpui.theme;
import rpui.events;
import rpui.widget;
import rpui.widgets.toolbar.widget;
import rpui.render.components;
import rpui.render.components_factory;
import rpui.render.renderer;
import rpui.render.transforms;

final class ToolbarRenderer : Renderer {
    private Toolbar widget;
    private Theme theme;

    private float height;
    private TexAtlasTextureQuad background;
    private QuadTransforms backgroundTransforms;

    override void onCreate(Widget widget, in string style) {
        this.theme = widget.view.theme;
        this.widget = cast(Toolbar) widget;
        this.background = createTexAtlasTextureQuadFromRdpl(theme, style, "background");
        this.widget.size.y = this.theme.tree.data.getNumber(style ~ ".height.0");
    }

    override void onRender() {
        renderTexAtlasQuad(theme, background, backgroundTransforms);
    }

    override void onProgress(in ProgressEvent event) {
        backgroundTransforms = updateQuadTransforms(
            widget.view.cameraView(),
            widget.absolutePosition,
            vec2(widget.size.x, background.texCoords.originalTexCoords.size.y)
        );
    }
}

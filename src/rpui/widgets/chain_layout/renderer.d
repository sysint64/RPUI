module rpui.widgets.chain_layout.renderer;

import std.container.array;

import rpui.math;
import rpui.theme;
import rpui.events;
import rpui.widget;
import rpui.widgets.chain_layout.widget;
import rpui.render.components;
import rpui.render.components_factory;
import rpui.render.renderer;
import rpui.render.transforms;

final class ChainLayoutRenderer : Renderer {
    private ChainLayout widget;
    private Theme theme;

    private vec2 splitOffset;
    private TexAtlasTextureQuad split;
    private Array!QuadTransforms splitTransforms;

    override void onCreate(Widget widget, in string style) {
        this.theme = widget.view.theme;
        this.widget = cast(ChainLayout) widget;

        this.split = createTexAtlasTextureQuadFromRdpl(theme, style, "split");
        this.splitOffset = theme.tree.data.getVec2f(style ~ ".splitOffset");
    }

    override void onRender() {
        widget.renderChildren();

        foreach (const transforms; splitTransforms) {
            renderTexAtlasQuad(theme, split, transforms);
        }
    }

    override void onProgress(in ProgressEvent event) {
        float splitPos = 0;
        splitTransforms.clear();

        foreach (Widget child; widget.children) {
            if (widget.children.back == child)
                continue;

            splitPos += child.associatedWidget.width;
            const transforms = updateQuadTransforms(
                widget.view.cameraView,
                widget.absolutePosition + vec2(splitPos, 0) + splitOffset,
                split.texCoords.originalTexCoords.size
            );
            splitTransforms.insert(transforms);
        }
    }
}

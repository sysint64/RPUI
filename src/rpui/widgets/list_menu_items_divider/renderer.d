module rpui.widgets.list_menu_items_divider.renderer;

import rpui.primitives;
import rpui.basic_rpdl_exts;
import rpui.math;
import rpui.theme;
import rpui.events;
import rpui.widget;
import rpui.widgets.list_menu_items_divider.widget;
import rpui.render.components;
import rpui.render.components_factory;
import rpui.render.renderer;
import rpui.render.transforms;

final class ListMenuItemsDividerRenderer : Renderer {
    private ListMenuItemsDivider widget;
    private Theme theme;

    private FrameRect dividerOffsets;
    private Geometry dividerInner;
    private Geometry dividerOuter;
    private QuadTransforms dividerInnerTransforms;
    private QuadTransforms dividerOuterTransforms;
    private vec4 innerColor;
    private vec4 outerColor;

    override void onCreate(Widget widget, in string style) {
        this.theme = widget.view.theme;
        this.widget = cast(ListMenuItemsDivider) widget;
        this.dividerInner = createGeometry();
        this.dividerOuter = createGeometry();
        this.dividerOffsets = this.theme.tree.data.getFrameRect(style ~ ".dividerOffsets");
        this.innerColor = this.theme.tree.data.getNormColor(style ~ ".innerColor");
        this.outerColor = this.theme.tree.data.getNormColor(style ~ ".outerColor");
        this.widget.height = 2 + this.dividerOffsets.top + this.dividerOffsets.bottom;
    }

    override void onRender() {
        renderColorQuad(theme, dividerInner, innerColor, dividerInnerTransforms);
        renderColorQuad(theme, dividerOuter, outerColor, dividerOuterTransforms);
    }

    override void onProgress(in ProgressEvent event) {
        const size = vec2(widget.size.x - dividerOffsets.left - dividerOffsets.right, 1);

        dividerInnerTransforms = updateQuadTransforms(
            widget.view.cameraView(),
            widget.absolutePosition + vec2(dividerOffsets.left, dividerOffsets.top - 1),
            size
        );

        dividerOuterTransforms = updateQuadTransforms(
            widget.view.cameraView(),
            widget.absolutePosition + vec2(dividerOffsets.left, dividerOffsets.top),
            size
        );
    }
}

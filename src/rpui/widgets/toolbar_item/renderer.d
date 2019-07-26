module rpui.widgets.toolbar_item.renderer;

import rpui.math;
import rpui.primitives;
import rpui.theme;
import rpui.events;
import rpui.widget;
import rpui.widgets.toolbar_item.widget;
import rpui.render.components;
import rpui.render.components_factory;
import rpui.render.renderer;
import rpui.render.transforms;

final class ToolbarItemRenderer : Renderer {
    private StatefulUiText text;
    private UiTextTransforms textTransforms;
    private ToolbarItem widget;
    private Theme theme;
    private Geometry iconQuad;
    private QuadTransforms iconTransforms;
    private vec2 iconBoxSize;

    override void onCreate(Widget widget, in string style) {
        this.theme = widget.view.theme;
        this.widget = cast(ToolbarItem) widget;
        this.text = createStatefulUiTextFromRdpl(theme, style, "Text");
        this.iconQuad = createGeometry();
        this.iconBoxSize = theme.tree.data.getVec2f(style ~ ".iconBoxSize");
    }

    override void onRender() {
        auto iconsResources = widget.view.resources.icons;
        const iconsTexture = iconsResources.getTextureForIcons(widget.iconsGroup);
        const icon = iconsResources.getIcon(widget.iconsGroup, widget.icon);

        renderTexAtlasQuad(
            theme,
            iconQuad,
            iconsTexture,
            icon.texCoord,
            iconTransforms
        );

        renderUiText(theme, text.render, text.attrs[text.state], textTransforms);
    }

    override void onProgress(in ProgressEvent event) {
        updateText();
        updateIcon();
    }

    private void updateText() {
        text.state = widget.state;

        with (text.attrs[text.state]) {
            caption = widget.caption;
            textVerticalAlign = VerticalAlign.bottom;
        }

        textTransforms = updateUiTextTransforms(
            &text.render,
            &theme.regularFont,
            textTransforms,
            text.attrs[text.state],
            widget.view.cameraView,
            widget.absolutePosition + widget.innerOffsetStart,
            widget.size
        );
    }

    private void updateIcon() {
        auto iconsResources = widget.view.resources.icons;
        const iconSize = iconsResources.getIconsConfig(widget.iconsGroup).size;

        const iconRelativePosition = vec2(
            alignBox(Align.center, iconSize.x, iconBoxSize.x),
            verticalAlignBox(VerticalAlign.middle, iconSize.y, iconBoxSize.y)
        );

        iconTransforms = updateQuadTransforms(
            widget.view.cameraView,
            widget.absolutePosition + iconRelativePosition,
            iconSize
        );
    }
}

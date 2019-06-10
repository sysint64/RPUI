module rpui.widgets.button.render_system;

import std.container.array;

import rpui.widgets.button;
import rpui.widgets.button.transforms_system;
import rpui.render.components_factory;
import rpui.render.components;
import rpui.render.renderer;
import rpui.theme;
import rpui.math;

import gapi.texture;

struct RenderData {
    StatefulChain background;
    Chain focusGlow;
    StatefulUiText captionText;
    Array!TexAtlasTextureQuad icons;
}

final class ButtonRenderSystem : RenderSystem {
    private Button widget;
    private Theme theme;
    private RenderTransforms* transforms;
    private RenderData* renderData;

    this(Button widget, RenderData* renderData, RenderTransforms* transforms) {
        this.widget = widget;
        this.theme = widget.view.theme;
        this.transforms = transforms;
        this.renderData = renderData;
    }

    override void onRender() {
        renderHorizontalChain(
            theme,
            renderData.background.parts,
            renderData.background.texCoords[widget.state],
            transforms.background,
            widget.partDraws
        );

        renderUiText(
            theme,
            renderData.captionText.render,
            renderData.captionText.attrs[widget.state],
            transforms.captionText,
        );

        if (widget.focusable && widget.isFocused) {
            renderHorizontalChain(
                theme,
                renderData.focusGlow.parts,
                renderData.focusGlow.texCoords,
                transforms.focusGlow,
                widget.partDraws
            );
        }

        renderIcons();
    }

    private void renderIcons() {
        for (int i = 0; i < widget.icons.length; ++i) {
            const iconTransforms = transforms.icons[i];
            const iconQuad = renderData.icons[i];

            renderTexAtlasQuad(
                theme,
                iconQuad.geometry,
                iconQuad.texture,
                iconQuad.texCoords,
                iconTransforms
            );
        }
    }
}

module rpui.widgets.button.render_system;

import rpui.widgets.button;
import rpui.widgets.button.transforms_system;
import rpui.render_factory;
import rpui.render_objects;
import rpui.renderer;
import rpui.theme;

struct RenderData {
    StatefulChain background;
    Chain focusGlow;
    StatefulUiText captionText;
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
    }
}

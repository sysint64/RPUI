module rpui.widgets.button.transforms_system;

import rpui.events;
import rpui.widgets.button;
import rpui.render_factory;
import rpui.render_objects;
import rpui.measure;
import rpui.theme;
import rpui.widgets.button.render_system;
import rpui.math;
import rpui.basic_types;
import rpui.widget;

struct RenderTransforms {
    HorizontalChainTransforms background;
    HorizontalChainTransforms focusGlow;
    UiTextTransforms captionText;
}

final class ButtonTransformsSystem : TransformsSystem {
    private RenderTransforms* transforms;
    private Button widget;
    private Theme theme;
    private RenderData* renderData;

    this(Button widget, RenderData* renderData, RenderTransforms* transforms) {
        this.widget = widget;
        this.theme = widget.view.theme;
        this.renderData = renderData;
        this.transforms = transforms;
    }

    override void onProgress(in ProgressEvent event) {
        updateBackground();
        updateText();
    }

    private void updateBackground() {
        transforms.background = updateHorizontalChainTransforms(
            renderData.background.widths,
            widget.view.cameraView,
            widget.absolutePosition,
            widget.size,
            widget.partDraws
        );

        if (widget.focusable && widget.isFocused) {
            transforms.focusGlow = updateHorizontalChainTransforms(
                renderData.background.widths,
                widget.view.cameraView,
                widget.absolutePosition + widget.measure.focusOffsets,
                widget.size + vec2(widget.measure.focusResize),
                widget.partDraws
            );
        }
    }

    private void updateText() {
        const textBoxSize = widget.size - vec2(widget.measure.iconsAreaSize, 0);
        auto textPosition = vec2(widget.measure.iconsAreaSize, 0) + widget.absolutePosition;

        if (widget.textAlign == Align.left) {
            textPosition.x += widget.measure.textLeftMargin;
        }
        else if (widget.textAlign == Align.right) {
            textPosition.x -= widget.measure.textRightMargin;
        }

        if (widget.partDraws == Widget.PartDraws.left || widget.partDraws == Widget.PartDraws.right) {
            textPosition.x -= 1;
        }

        with (renderData.captionText.attrs[widget.state]) {
            caption = widget.caption;
            textAlign = widget.textAlign;
            textVerticalAlign = widget.textVerticalAlign;
        }

        transforms.captionText = updateUiTextTransforms(
            &renderData.captionText.render,
            &theme.regularFont,
            transforms.captionText,
            renderData.captionText.attrs[widget.state],
            widget.view.cameraView,
            textPosition,
            textBoxSize
        );

        widget.measure.textWidth = transforms.captionText.size.x;
    }
}

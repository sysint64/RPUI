module rpui.widgets.button.transforms_system;

import std.container.array;
import std.math;
import std.algorithm;

import rpui.events;
import rpui.widgets.button.widget;
import rpui.render.components_factory;
import rpui.render.components;
import rpui.render.transforms;
import rpui.theme;
import rpui.widgets.button.render_system;
import rpui.math;
import rpui.primitives;
import rpui.widget;

struct RenderTransforms {
    HorizontalChainTransforms background;
    HorizontalChainTransforms focusGlow;
    UiTextTransforms captionText;
    Array!QuadTransforms icons;
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
        updateIcons();
    }

    private void updateBackground() {
        const uselseeBorderSize = vec2(
            widget.measure.uselessBorders.left + widget.measure.uselessBorders.right,
            0
            // widget.measure.uselessBorders.top + widget.measure.uselessBorders.bottom
        );

        transforms.background = updateHorizontalChainTransforms(
            renderData.background.widths,
            widget.view.cameraView,
            widget.absolutePosition - vec2(widget.measure.uselessBorders.left, -widget.measure.uselessBorders.bottom),
            widget.size + uselseeBorderSize,
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
        if (widget.caption == "") {
            widget.measure.textWidth = 0;
            return;
        }

        const captionTransforms = getCaptonTransforms(widget.textAlign);

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
            captionTransforms.position,
            captionTransforms.size
        );

        widget.measure.textWidth = transforms.captionText.size.x;
    }

    struct CaptionTransforms {
        vec2 position;
        vec2 size;
    }

    CaptionTransforms getCaptonTransforms(in Align textAlign) {
        const textBoxSize = widget.size - vec2(widget.measure.iconsAreaSize, 0);
        auto textPosition = vec2(widget.measure.iconsAreaSize, 0) + widget.absolutePosition;

        if (textAlign == Align.left) {
            textPosition.x += widget.measure.textLeftMargin;
        }
        else if (textAlign == Align.right) {
            textPosition.x -= widget.measure.textRightMargin;
        }

        if (widget.partDraws == Widget.PartDraws.left || widget.partDraws == Widget.PartDraws.right) {
            textPosition.x -= 1;
        }

        return CaptionTransforms(
            textPosition,
            textBoxSize
        );
    }

    private void updateIcons() {
        with (widget) {
            measure.iconsAreaSize = 0;

            const iconSize = view.resources.icons.getIconsConfig(iconsGroup).size;
            const iconVerticalOffset = round((size.y - iconSize.y) / 2.0f);
            float iconLastOffset = 0;
            int counter = 0;

            for (int i = 0; i < widget.icons.length; ++i) {
                const iconOffset = iconLastOffset;

                iconLastOffset = iconOffset + iconSize.x + measure.iconGaps;
                counter++;
                const offset = measure.iconOffsets + vec2(iconOffset, iconVerticalOffset);

                const transform = updateQuadTransforms(
                    view.cameraView,
                    absolutePosition + offset,
                    iconSize
                );
                transforms.icons[i] = transform;
            }

            if (icons.length > 0) {
                measure.iconsAreaSize += iconLastOffset - measure.iconGaps * 2;
            }

            if (widget.uselessIconArea != 0) {
                const count = max(icons.length, widget.uselessIconArea);
                measure.iconsAreaSize = (iconSize.x + measure.iconGaps) * count - measure.iconGaps * 2;
            }
        }
    }
}

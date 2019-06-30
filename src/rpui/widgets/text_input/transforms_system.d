module rpui.widgets.text_input.transforms_system;

import std.container.array;
import std.math;

import rpui.events;
import rpui.widgets.text_input;
import rpui.render.components_factory;
import rpui.render.components;
import rpui.render.transforms;
import rpui.theme;
import rpui.widgets.text_input.render_system;
import rpui.math;
import rpui.primitives;
import rpui.widget;

struct RenderTransforms {
    vec2 focusOffsets;
    float focusResize;
    float selectRegionHeight;
    vec2 selectRegionOffset;
    vec2 arrowOffsets;

    HorizontalChainTransforms background;
    HorizontalChainTransforms focusGlow;
    QuadTransforms carriage;
    UiTextTransforms text;
    QuadTransforms selectRegion;
    QuadTransforms leftArrow;
    QuadTransforms rightArrow;
}

final class TextInputTransformsSystem : TransformsSystem {
    private RenderTransforms* transforms;
    private TextInput widget;
    private Theme theme;
    private RenderData* renderData;

    this(TextInput widget, RenderData* renderData, RenderTransforms* transforms) {
        this.widget = widget;
        this.theme = widget.view.theme;
        this.renderData = renderData;
        this.transforms = transforms;
    }

    override void onProgress(in ProgressEvent event) {
        updateBackground();
        updateCarriage();
        updateText();
        updateSelectRegion();
        updateArrows();
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
                widget.absolutePosition + transforms.focusOffsets,
                widget.size + vec2(transforms.focusResize),
                widget.partDraws
            );
        }
    }

    private void updateCarriage() {
         transforms.carriage = updateQuadTransforms(
            widget.view.cameraView,
            widget.editComponent.carriage.absolutePosition,
            renderData.carriage.texCoords.originalTexCoords.size
        );
    }

    private void updateArrows() {
        renderData.leftArrow.state = widget.numberInputTypeComponent.leftArrow.state;
        renderData.rightArrow.state = widget.numberInputTypeComponent.rightArrow.state;

        updateArrowAbsolutePositions();

        transforms.leftArrow = updateQuadTransforms(
            widget.view.cameraView,
            widget.numberInputTypeComponent.leftArrow.absolutePosition,
            renderData.leftArrow.currentTexCoords.originalTexCoords.size
        );

        transforms.rightArrow = updateQuadTransforms(
            widget.view.cameraView,
            widget.numberInputTypeComponent.rightArrow.absolutePosition,
            renderData.rightArrow.currentTexCoords.originalTexCoords.size
        );
    }

    private void updateArrowAbsolutePositions() {
        with (widget.numberInputTypeComponent) {
            leftArrow.absolutePosition = widget.absolutePosition + transforms.arrowOffsets;

            const rightArrowWidth = renderData.rightArrow.currentTexCoords.originalTexCoords.size.x;
            const rightArrowOffsets = vec2(
                widget.size.x - rightArrowWidth - transforms.arrowOffsets.x,
                transforms.arrowOffsets.y
            );

            rightArrow.absolutePosition = widget.absolutePosition + rightArrowOffsets;
        }
    }

    private void updateText() {
        with (renderData.text.attrs[widget.state]) {
            caption = widget.editComponent.text;
            textAlign = widget.textAlign;
        }

        updateTextPosition();
        transforms.text = updateUiTextTransforms(
            &renderData.text.render,
            &theme.regularFont,
            transforms.text,
            renderData.text.attrs[widget.state],
            widget.view.cameraView,
            widget.editComponent.absoulteTextPosition,
            widget.size
        );

        widget.measure.textWidth = transforms.text.size.x;
        widget.measure.lineHeight = transforms.text.size.y;
        widget.measure.textRelativePosition = vec2(transforms.text.relativePosition.x, 0);
    }

    private void updateTextPosition() {
        auto textPosition = widget.absolutePosition;

        if (widget.textAlign == Align.left) {
            textPosition.x += widget.measure.textLeftMargin + widget.editComponent.scrollDelta;
        }
        else if (widget.textAlign == Align.right) {
            textPosition.x -= widget.measure.textRightMargin - widget.editComponent.scrollDelta;
        }

        widget.editComponent.absoulteTextPosition = textPosition;
    }

    package float getRegionTextWidth(in int start, in int end) {
        auto attrs = renderData.text.attrs[widget.state];
        attrs.caption = widget.editComponent.text[start .. end];
        return getUiTextBounds(&renderData.text.render, &theme.regularFont, attrs).x;
    }

    private void updateSelectRegion() {
        with (widget.editComponent) {
            if (!selectRegion.textIsSelected())
                return;

            const regionSize = getRegionTextWidth(selectRegion.start, selectRegion.end);

            selectRegion.size = vec2(regionSize, transforms.selectRegionHeight);
            selectRegion.absolutePosition = widget.absolutePosition +
                getTextRegionOffset(selectRegion.start) +
                transforms.selectRegionOffset;

            transforms.selectRegion = updateQuadTransforms(
                widget.view.cameraView,
                selectRegion.absolutePosition,
                selectRegion.size
            );
        }
    }
}

module rpui.widgets.panel.transforms_system;

import rpui.events;
import rpui.theme;
import rpui.basic_types;
import rpui.widgets.panel;
import rpui.widgets.panel.render_system;
import rpui.measure;
import rpui.render_objects;

import gapi.transform;
import gapi.vec;

struct RenderTransforms {
    QuadTransforms background;
    QuadTransforms splitInner;
    QuadTransforms splitOuter;
    HorizontalChainTransforms horizontalScrollButton;
    HorizontalChainTransforms verticalScrollButton;
    QuadTransforms headerBackground;
    QuadTransforms headerMark;
    UiTextTransforms headerText;
}

struct SplitTransforms {
    vec2 size;
    vec2 innerPosition;
    vec2 outerPosition;
}

final class PanelTransformsSystem : TransformsSystem {
    private RenderTransforms* transforms;
    private Panel widget;
    private RenderData* renderData;
    private Theme theme;

    this(Panel widget, RenderData* renderData, RenderTransforms* transforms) {
        this.renderData = renderData;
        this.transforms = transforms;
        this.theme = widget.view.theme;
        this.widget = widget;
    }

    override void onProgress(in ProgressEvent event) {
        updateBackgroundTransforms();
        updateHeaderTransforms();
        updateSplitTransforms();
        updateScrollButtonsTransforms();
    }

    private void updateBackgroundTransforms() {
        transforms.background = updateQuadTransforms(
            widget.view.cameraView,
            widget.absolutePosition,
            widget.size
        );
    }

    private void updateHeaderTransforms() {
        if (!widget.userCanHide)
            return;

        const headerSize = vec2(widget.size.x, widget.measure.headerHeight);

        transforms.headerBackground = updateQuadTransforms(
            widget.view.cameraView,
            widget.absolutePosition,
            headerSize
        );

        transforms.headerMark = updateQuadTransforms(
            widget.view.cameraView,
            widget.absolutePosition + renderData.headerMarkPosition,
            renderData.headerMarkSize
        );

        const textPosition = widget.absolutePosition +
            vec2(renderData.headerMarkPosition.x + renderData.headerMarkSize.x, 0);

        with (renderData.headerText.attrs[widget.headerState]) {
            caption = widget.caption;
        }

        transforms.headerText = updateUiTextTransforms(
            &renderData.headerText.render,
            &theme.regularFont,
            transforms.headerText,
            renderData.headerText.attrs[widget.headerState],
            widget.view.cameraView,
            textPosition,
            headerSize
        );
    }

    private void updateSplitTransforms() {
        if (!widget.userCanResize && !widget.showSplit)
            return;

        const splitTransforms = getSplitTransforms();

        transforms.splitInner = updateQuadTransforms(
            widget.view.cameraView,
            splitTransforms.innerPosition,
            splitTransforms.size
        );

        transforms.splitOuter = updateQuadTransforms(
            widget.view.cameraView,
            splitTransforms.outerPosition,
            splitTransforms.size
        );

        widget.split.cursorRangeRect = Rect(
            splitTransforms.outerPosition,
            splitTransforms.size
        );
    }

    private SplitTransforms getSplitTransforms() {
        vec2 size;
        vec2 innerPosition;
        vec2 outerPosition;

        const thickness = widget.split.thickness;

        switch (widget.regionAlign) {
            case RegionAlign.top:
                outerPosition = widget.absolutePosition + vec2(0, widget.size.y - thickness);
                innerPosition = outerPosition - vec2(0, thickness);
                size = vec2(widget.size.x, thickness);
                break;

            case RegionAlign.bottom:
                outerPosition = widget.absolutePosition;
                innerPosition = outerPosition + vec2(0, thickness);
                size = vec2(widget.size.x, thickness);
                break;

            case RegionAlign.left:
                outerPosition = widget.absolutePosition + vec2(widget.size.x - thickness, 0);
                innerPosition = outerPosition - vec2(thickness, 0);
                size = vec2(thickness, widget.size.y);
                break;

            case RegionAlign.right:
                outerPosition = widget.absolutePosition;
                innerPosition = outerPosition + vec2(thickness, 0);
                size = vec2(thickness, widget.size.y);
                break;

            default:
                return SplitTransforms();
        }

        return SplitTransforms(size, innerPosition, outerPosition);
    }

    private void updateScrollButtonsTransforms() {
        if (widget.horizontalScrollButton.visible) {
            transforms.horizontalScrollButton = updateHorizontalChainTransforms(
                renderData.horizontalScrollButton.widths,
                widget.view.cameraView,
                widget.absolutePosition + widget.horizontalScrollButton.buttonOffset,
                vec2(
                    widget.horizontalScrollButton.buttonSize,
                    widget.measure.horizontalScrollRegionWidth
                )
            );
        }

        if (widget.verticalScrollButton.visible) {
            transforms.verticalScrollButton = updateVerticalChainTransforms(
                renderData.verticalScrollButton.widths,
                widget.view.cameraView,
                widget.absolutePosition + widget.verticalScrollButton.buttonOffset,
                vec2(
                    widget.measure.verticalScrollRegionWidth,
                    widget.verticalScrollButton.buttonSize
                )
            );
        }
    }
}

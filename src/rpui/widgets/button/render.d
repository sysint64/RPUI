module rpui.widgets.button.render;

import std.traits;

import rpdl;
import gapi.geometry;
import gapi.vec;
import gapi.texture;
import gapi.text;

import rpui.widgets.button;
import rpui.events;
import rpui.widget;
import rpui.render_objects;
import rpui.render_factory;
import rpui.renderer;
import rpui.measure;
import rpui.theme;
import rpui.basic_types;

struct RenderData {
    StatefulHorizontalChain background;
    HorizontalChain focusGlow;
    StatefulUiText captionText;
}

struct RenderTransforms {
    HorizontalChainTransforms background;
    HorizontalChainTransforms focusGlow;
    UiTextTransforms captionText;
}

RenderData readRenderData(Theme theme, in string style) {
    RenderData renderData;

    renderData.background = createStatefulHorizontalChainFromRdpl(theme, style);
    renderData.focusGlow = createHorizontalChainFromRdpl(theme, style ~ ".Focus");
    renderData.captionText = createStatefulUiText(theme, style);

    return renderData;
}

void render(
    in Button widget,
    in Theme theme,
    in RenderData renderData,
    in RenderTransforms transforms
) {
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

void updateRenderTransforms(
    Button widget,
    RenderTransforms* transforms,
    RenderData* renderData,
    Theme* theme
) {
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

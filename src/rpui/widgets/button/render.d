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
import rpui.theme;
import rpui.basic_types;

struct RenderData {
    StatefulTextureQuad[ChainPart] background;
    TextureQuad[ChainPart] focusGlow;
    UiText captionText;
    RenderDataMeasure measure;
    UiTextAttributes[State] captionTextAttrs;
}

struct RenderDataMeasure {
    StatefulTextureHorizontalChainMeasure background;
    UiTextMeasure captionText;
}

RenderData readRenderData(Theme theme, in string style) {
    RenderData renderData;

    foreach (immutable part; [EnumMembers!ChainPart]) {
        renderData.background[part] = createStatefulChainPartFromRdpl(theme, style, part);
        renderData.focusGlow[part] = createChainPartFromRdpl(theme, style ~ ".Focus", part);
    }

    renderData.captionText = createUiText();

    foreach (immutable state; [EnumMembers!State]) {
        renderData.captionTextAttrs[state] = createTextAttributesFromRdpl(theme, style ~ getStateRdplName(state));
    }

    return renderData;
}

void render(Button widget, in Theme theme, in RenderData renderData) {
    renderStatefulTextureHorizontalChain(
        theme,
        renderData.background,
        renderData.measure.background,
        widget.state,
        widget.partDraws
    );

    renderUiText(
        theme,
        renderData.captionText,
        renderData.captionTextAttrs[widget.state],
        renderData.measure.captionText,
    );
}

RenderDataMeasure updateRenderDataMeasure(Button widget, RenderData* renderData, Theme* theme) {
    RenderDataMeasure measure;

    measure.background = measureStatefulTextureHorizontalChain(
        widget.renderData.background,
        widget.view.cameraView,
        widget.absolutePosition,
        widget.size,
        widget.state,
        widget.partDraws
    );

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

    with (renderData.captionTextAttrs[widget.state]) {
        fontSize = theme.regularFontSize;
        caption = widget.caption;
        textAlign = widget.textAlign;
        textVerticalAlign = widget.textVerticalAlign;
    }

    measure.captionText = measureUiTextFixedSize(
        &renderData.captionText,
        &theme.regularFont,
        renderData.captionTextAttrs[widget.state],
        widget.view.cameraView,
        textPosition,
        textBoxSize
    );

    widget.measure.textWidth = measure.captionText.size.x;
    return measure;
}

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
    RenderDataTransforms transforms;
}

struct RenderDataTransforms {
    HorizontalChainTransforms background;
    UiTextTransforms captionText;
}

RenderData readRenderData(Theme theme, in string style) {
    RenderData renderData;

    renderData.background = createStatefulHorizontalChainFromRdpl(theme, style);
    renderData.focusGlow = createHorizontalChainFromRdpl(theme, style ~ ".Focus");
    renderData.captionText = createStatefulUiText(theme, style);

    return renderData;
}

void render(Button widget, in Theme theme, in RenderData renderData) {
    renderHorizontalChain(
        theme,
        renderData.background.parts,
        renderData.background.texCoords[widget.state],
        renderData.transforms.background,
        widget.partDraws
    );

    renderUiText(
        theme,
        renderData.captionText.render,
        renderData.captionText.attrs[widget.state],
        renderData.transforms.captionText,
    );
}

RenderDataTransforms updateRenderDataTransforms(Button widget, RenderData* renderData, Theme* theme) {
    RenderDataTransforms transforms;

    transforms.background = updateHorizontalChainTransforms(
        renderData.background.widths,
        widget.view.cameraView,
        widget.absolutePosition,
        widget.size,
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

    with (renderData.captionText.attrs[widget.state]) {
        fontSize = theme.regularFontSize;
        caption = widget.caption;
        textAlign = widget.textAlign;
        textVerticalAlign = widget.textVerticalAlign;
    }

    transforms.captionText = updateUiTextTransforms(
        &renderData.captionText.render,
        &theme.regularFont,
        renderData.captionText.attrs[widget.state],
        widget.view.cameraView,
        textPosition,
        textBoxSize
    );

    widget.measure.textWidth = transforms.captionText.size.x;
    return transforms;
}

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
    TextureQuad[ChainPart] background;
    TextureQuad[ChainPart] focusGlow;
    float[ChainPart] backgroundWidths;
    OriginalWithNormilizedTextureCoords focusGlowTextureCoords;
    OriginalWithNormilizedTextureCoords[ChainPart][State] backgroundTextureCoords;
    UiText captionText;
    UiTextAttributes[State] captionTextAttrs;

    RenderDataTransforms transforms;
}

struct RenderDataTransforms {
    HorizontalChainTransforms background;
    UiTextTransforms captionText;
}

RenderData readRenderData(Theme theme, in string style) {
    RenderData renderData;

    foreach (immutable part; [EnumMembers!ChainPart]) {
        renderData.background[part] = createChainPartFromRdpl(theme);
        renderData.focusGlow[part] = createChainPartFromRdpl(theme);
        renderData.focusGlowTextureCoords = createOriginalWithNormilizedTextureCoordsFromRdpl(
            theme, style ~ ".Focus." ~ getChainPartRdplName(part)
        );

        foreach (immutable state; [EnumMembers!State]) {
            renderData.backgroundTextureCoords[state][part] = createOriginalWithNormilizedTextureCoordsFromRdpl(
                theme, style ~ "." ~ getStateRdplName(state) ~ "." ~ getChainPartRdplName(part)
            );
            renderData.backgroundWidths[part] = renderData.backgroundTextureCoords[state][part].texCoords.size.x;
        }
    }

    renderData.captionText = createUiText();

    foreach (immutable state; [EnumMembers!State]) {
        renderData.captionTextAttrs[state] = createTextAttributesFromRdpl(theme, style ~ "." ~ getStateRdplName(state));
    }

    return renderData;
}

void render(Button widget, in Theme theme, in RenderData renderData) {
    const texCoords = [
        ChainPart.left: renderData.backgroundTextureCoords[widget.state][ChainPart.left].normilizedTexCoords,
        ChainPart.center: renderData.backgroundTextureCoords[widget.state][ChainPart.center].normilizedTexCoords,
        ChainPart.right: renderData.backgroundTextureCoords[widget.state][ChainPart.right].normilizedTexCoords
    ];

    renderHorizontalChain(
        theme,
        renderData.background,
        texCoords,
        renderData.transforms.background,
        widget.partDraws
    );

    renderUiText(
        theme,
        renderData.captionText,
        renderData.captionTextAttrs[widget.state],
        renderData.transforms.captionText,
    );
}

RenderDataTransforms updateRenderDataTransforms(Button widget, RenderData* renderData, Theme* theme) {
    RenderDataTransforms transforms;

    transforms.background = updateHorizontalChainTransforms(
        renderData.backgroundWidths,
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

    with (renderData.captionTextAttrs[widget.state]) {
        fontSize = theme.regularFontSize;
        caption = widget.caption;
        textAlign = widget.textAlign;
        textVerticalAlign = widget.textVerticalAlign;
    }

    transforms.captionText = updateUiTextTransforms(
        &renderData.captionText,
        &theme.regularFont,
        renderData.captionTextAttrs[widget.state],
        widget.view.cameraView,
        textPosition,
        textBoxSize
    );

    widget.measure.textWidth = transforms.captionText.size.x;
    return transforms;
}

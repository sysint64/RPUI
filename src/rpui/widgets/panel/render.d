module rpui.widgets.panel.render;

import rpui.theme;
import rpui.math;
import rpui.widget;
import rpui.widgets.panel;
import rpui.render_objects;
import rpui.render_factory;
import rpui.measure;
import rpui.renderer;
import rpui.basic_types;

import gapi.texture;

enum SplitColor {
    darkInner,
    darkOuter,
    lightInner,
    lightOuter,
}

struct RenderData {
    vec4[Panel.Background] backgroundColors;
    vec4[SplitColor] splitColors;
    float splitThickness;
    Geometry background;
    Geometry splitInner;
    Geometry splitOuter;
    StatefulChain horizontalScrollButton;
    StatefulChain verticalScrollButton;
    StatefulTexAtlasTextureQuad headerBackground;
    TextureQuad headerMark;
    Texture2DCoords headerOpenMarkTexCoords;
    Texture2DCoords headerCloseMarkTexCoords;
    StatefulUiText headerText;
    vec2 headerMarkSize;
    vec2 headerMarkPosition;
}

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

class PanelRenderer : Renderer {
    override void onRender() {
    }

    override void onProgress() {
    }
}

RenderData readRenderData(Theme theme, in string style) {
    with (theme.tree) {
        RenderData renderData = {
            backgroundColors: [
                Panel.Background.light: data.getNormColor(style ~ ".backgroundLight"),
                Panel.Background.dark: data.getNormColor(style ~ ".backgroundDark"),
                Panel.Background.action: data.getNormColor(style ~ ".backgroundAction"),
            ],
            splitColors: [
                SplitColor.darkInner: data.getNormColor(style ~ ".Split.Dark.innerColor"),
                SplitColor.darkOuter: data.getNormColor(style ~ ".Split.Dark.outerColor"),
                SplitColor.lightInner: data.getNormColor(style ~ ".Split.Light.innerColor"),
                SplitColor.lightOuter: data.getNormColor(style ~ ".Split.Light.outerColor"),
            ],
            splitThickness: data.getNumber(style ~ ".Split.thickness.0"),
            background: createGeometry(),
            splitInner: createGeometry(),
            splitOuter: createGeometry(),
            headerBackground: createStatefulTexAtlasTextureQuadFromRdpl(
                theme,
                style ~ ".Header", "background",
                [State.leave, State.enter]
            ),
            headerText: createStatefulUiText(
                theme,
                style ~ ".Header", "Text",
                [State.leave, State.enter]
            ),
            headerMarkSize: data.getVec2f(style ~ ".Header.Mark.size"),
            headerMarkPosition: data.getVec2f(style ~ ".Header.Mark.position"),
            headerMark: createUiSkinTextureQuad(theme),
            headerOpenMarkTexCoords: createNormilizedTextureCoordsFromRdpl(
                theme,
                style ~ ".Header.Mark.open"
            ),
            headerCloseMarkTexCoords: createNormilizedTextureCoordsFromRdpl(
                theme,
                style ~ ".Header.Mark.close"
            ),
            horizontalScrollButton: createStatefulChainFromRdpl(
                theme,
                Orientation.horizontal,
                style ~ ".Scroll.Horizontal.Button"
            ),
            verticalScrollButton: createStatefulChainFromRdpl(
                theme,
                Orientation.vertical,
                style ~ ".Scroll.Vertical.Button"
            ),
        };

        return renderData;
    }
}

void updateRenderTransforms(
    Panel widget,
    RenderTransforms* transforms,
    RenderData* renderData,
    Theme* theme
) {
    widget.header.height = widget.measure.headerHeight;
    transforms.background = updateQuadTransforms(
        widget.view.cameraView,
        widget.absolutePosition,
        widget.size
    );

    if (widget.userCanHide) {
        const headerSize = vec2(widget.size.x, widget.measure.headerHeight);

        transforms.headerBackground = updateQuadTransforms(
            widget.view.cameraView,
            widget.absolutePosition,
            headerSize
        );

        transforms.headerMark = updateQuadTransforms(
            widget.view.cameraView,
            renderData.headerMarkPosition,
            renderData.headerMarkSize
        );

        const textPosition = widget.absolutePosition +
            vec2(renderData.headerMarkPosition.x + renderData.headerMarkSize.x, 0);

        renderData.headerText.attrs[widget.header.state].caption = widget.caption;
        transforms.headerText = updateUiTextTransforms(
            &renderData.headerText.render,
            &theme.regularFont,
            transforms.headerText,
            renderData.headerText.attrs[widget.header.state],
            widget.view.cameraView,
            textPosition,
            headerSize
        );
    }

    if (widget.userCanResize || widget.showSplit) {
        const splitTransforms = getSplitTransforms(widget, *renderData);

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

private SplitTransforms getSplitTransforms(Panel panel, in RenderData renderData) {
    vec2 size;
    vec2 innerPosition;
    vec2 outerPosition;

    const thickness = renderData.splitThickness;

    switch (panel.regionAlign) {
        case RegionAlign.top:
            outerPosition = panel.absolutePosition + vec2(0, panel.size.y - thickness);
            innerPosition = outerPosition - vec2(0, thickness);
            size = vec2(panel.size.x, thickness);
            break;

        case RegionAlign.bottom:
            outerPosition = panel.absolutePosition;
            innerPosition = outerPosition + vec2(0, thickness);
            size = vec2(panel.size.x, thickness);
            break;

        case RegionAlign.left:
            outerPosition = panel.absolutePosition + vec2(panel.size.x - thickness, 0);
            innerPosition = outerPosition - vec2(thickness, 0);
            size = vec2(thickness, panel.size.y);
            break;

        case RegionAlign.right:
            outerPosition = panel.absolutePosition;
            innerPosition = outerPosition + vec2(thickness, 0);
            size = vec2(thickness, panel.size.y);
            break;

        default:
            return SplitTransforms();
    }

    return SplitTransforms(size, innerPosition, outerPosition);
}

void render(
    Panel widget,
    in Theme theme,
    in RenderData renderData,
    in RenderTransforms transforms
) {
    renderBackground(widget, theme, renderData, transforms);
    renderHeader(widget, theme, renderData, transforms);

    if (!widget.isOpen) {
        renderSplit(widget, theme, renderData, transforms);
        return;
    }

    const scissor = getScissor(widget, renderData);
    widget.view.pushScissor(scissor);

    foreach (Widget child; widget.children) {
        if (!child.visible)
            continue;

        if (!pointInRect(widget.view.mousePos, scissor)) {
            child.isEnter = false;
            child.isClick = false;
        }

        child.onRender();
    }

    widget.view.popScissor();
    renderSplit(widget, theme, renderData, transforms);
    renderScrollButtons(widget, theme, renderData, transforms);
}

private Rect getScissor(Panel widget, in RenderData renderData) {
    Rect scissor;
    const thickness = renderData.splitThickness;

    with (widget) {
        scissor.point = absolutePosition + extraInnerOffsetStart;
        scissor.size = size;

        if (userCanHide) {
            scissor.size = scissor.size - vec2(0, header.height);
        }

        if (userCanResize || showSplit) {
            if (regionAlign == RegionAlign.top || regionAlign == RegionAlign.bottom) {
                // Horizontal orientation
                scissor.size = scissor.size - vec2(0, thickness);
            }
            else if (regionAlign == RegionAlign.left || regionAlign == RegionAlign.right) {
                // Vertical orientation
                scissor.size = scissor.size - vec2(thickness, 0);
            }
        }
    }

    return scissor;
}

private void renderBackground(
    in Panel widget,
    in Theme theme,
    in RenderData renderData,
    in RenderTransforms transforms
) {
    if (widget.background == Panel.Background.transparent) {
        return;
    }

    renderColorQuad(
        theme,
        renderData.background,
        renderData.backgroundColors[widget.background],
        transforms.background
    );
}

private void renderSplit(
    in Panel widget,
    in Theme theme,
    in RenderData renderData,
    in RenderTransforms transforms
) {
    if (!widget.showSplit)
        return;

    const innerColor = widget.darkSplit
        ? renderData.splitColors[SplitColor.darkInner]
        : renderData.splitColors[SplitColor.lightInner];

    const outerColor = widget.darkSplit
        ? renderData.splitColors[SplitColor.darkOuter]
        : renderData.splitColors[SplitColor.lightOuter];

    renderColorQuad(
        theme,
        renderData.splitInner,
        innerColor,
        transforms.splitInner
    );

    renderColorQuad(
        theme,
        renderData.splitOuter,
        outerColor,
        transforms.splitOuter
    );
}

private void renderHeader(
    in Panel widget,
    in Theme theme,
    in RenderData renderData,
    in RenderTransforms transforms
) {
    if (!widget.userCanHide)
        return;

    renderTexAtlasQuad(
        theme,
        renderData.headerBackground.geometry,
        renderData.headerBackground.texture,
        renderData.headerBackground.texCoords[widget.header.state].normilizedTexCoords,
        transforms.headerBackground
    );

    Texture2DCoords markTexCoords;

    if (widget.isOpen) {
        markTexCoords = renderData.headerOpenMarkTexCoords;
    } else {
        markTexCoords = renderData.headerCloseMarkTexCoords;
    }

    renderTexAtlasQuad(
        theme,
        renderData.headerMark.geometry,
        renderData.headerMark.texture,
        markTexCoords,
        transforms.headerMark
    );

    renderUiText(
        theme,
        renderData.headerText.render,
        renderData.headerText.attrs[widget.header.state],
        transforms.headerText,
    );
}

private void renderScrollButtons(
    in Panel widget,
    in Theme theme,
    in RenderData renderData,
    in RenderTransforms transforms
) {
    if (widget.horizontalScrollButton.visible) {
        renderHorizontalChain(
            theme,
            renderData.horizontalScrollButton.parts,
            renderData.horizontalScrollButton.texCoords[widget.horizontalScrollButton.state],
            transforms.horizontalScrollButton,
            widget.partDraws
        );
    }

    if (widget.verticalScrollButton.visible) {
        renderVerticalChain(
            theme,
            renderData.verticalScrollButton.parts,
            renderData.verticalScrollButton.texCoords[widget.verticalScrollButton.state],
            transforms.verticalScrollButton
        );
    }
}

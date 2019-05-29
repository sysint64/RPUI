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
}

struct RenderTransforms {
    QuadTransforms background;
    QuadTransforms splitInner;
    QuadTransforms splitOuter;
}

struct SplitTransforms {
    vec2 size;
    vec2 innerPosition;
    vec2 outerPosition;
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
    transforms.background = updateQuadTransforms(
        widget.view.cameraView,
        widget.absolutePosition,
        widget.size
    );

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
}

private Rect getScissor(Panel widget, in RenderData renderData) {
    Rect scissor;
    const thickness = renderData.splitThickness;

    with (widget) {
        scissor.point = absolutePosition + extraInnerOffsetStart;
        scissor.size = size;

        if (userCanHide) {
            // scissor.size = scissor.size - vec2(0, header.height);
        }

        if (userCanResize && darkSplit) {
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
}

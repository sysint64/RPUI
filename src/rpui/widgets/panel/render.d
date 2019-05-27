module rpui.widgets.panel.render;

import rpui.theme;
import rpui.math;
import rpui.widget;
import rpui.widgets.panel;
import rpui.render_objects;
import rpui.render_factory;
import rpui.measure;
import rpui.renderer;

enum SplitColor {
    darkInner,
    darkOuter,
    lightInner,
    lightOuter,
}

struct RenderData {
    vec4[Panel.Background] backgroundColors;
    vec4[SplitColor] spliltColors;
    Geometry backgroundQuad;
}

struct RenderTransforms {
    QuadTransforms background;
}

RenderData readRenderData(Theme theme, in string style) {
    with (theme.tree) {
        RenderData renderData = {
            backgroundColors: [
                Panel.Background.light: data.getNormColor(style ~ ".backgroundLight"),
                Panel.Background.dark: data.getNormColor(style ~ ".backgroundDark"),
                Panel.Background.action: data.getNormColor(style ~ ".backgroundAction"),
            ],
            spliltColors: [
                SplitColor.darkInner: data.getNormColor(style ~ ".Split.Dark.innerColor"),
                SplitColor.darkOuter: data.getNormColor(style ~ ".Split.Dark.outerColor"),
                SplitColor.lightInner: data.getNormColor(style ~ ".Split.Light.innerColor"),
                SplitColor.lightOuter: data.getNormColor(style ~ ".Split.Light.outerColor"),
            ],
            backgroundQuad: createGeometry(),
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
}

void render(
    Panel widget,
    in Theme theme,
    in RenderData renderData,
    in RenderTransforms transforms
) {
    renderBackground(widget, theme, renderData, transforms);

    foreach (Widget child; widget.children) {
        if (!child.visible)
            continue;

        // if (!pointInRect(app.mousePos, scissor)) {
            // child.isEnter = false;
            // child.isClick = false;
        // }

        child.onRender();
    }
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
        renderData.backgroundQuad,
        renderData.backgroundColors[widget.background],
        transforms.background
    );
}

module rpui.widgets.button.render;

import std.traits;

import rpdl;
import gapi.geometry;
import gapi.vec;
import gapi.texture;

import rpui.widgets.button;
import rpui.events;
import rpui.widget;
import rpui.render_objects;
import rpui.render_factory;
import rpui.renderer;
import rpui.theme;

struct RenderData {
    StatefulTextureQuad[ChainPart] background;
    TextureQuad[ChainPart] focusGlow;
    RenderDataMeasure measure;
}

struct RenderDataMeasure {
    StatefulTextureHorizontalChainMeasure background;
}

RenderData readRenderData(Theme theme, in string style) {
    RenderData renderData;

    foreach (immutable part; [EnumMembers!ChainPart]) {
        renderData.background[part] = createStatefulChainPartFromRdpl(theme, style, part);
        renderData.focusGlow[part] = createChainPartFromRdpl(theme, style ~ ".Focus", part);
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
}

RenderDataMeasure updateRenderDataMeasure(Button widget) {
    RenderDataMeasure measure;

    measure.background = measureStatefulTextureHorizontalChain(
        widget.renderData.background,
        widget.view.cameraView,
        widget.absolutePosition,
        widget.size,
        widget.state,
        widget.partDraws
    );

    return measure;
}

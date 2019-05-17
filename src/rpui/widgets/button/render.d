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
    vec2 backgroundPosition;
    vec2 backgroundSize;
    vec2 focusGlowPosition;
    vec2 focusGlowSize;
}

RenderData readRenderData(Theme theme, in string style) {
    RenderData renderData;

    foreach (immutable part; [EnumMembers!ChainPart]) {
        renderData.background[part] = createStatefulChainPartFromRdpl(theme, style, part);
        renderData.focusGlow[part] = createChainPartFromRdpl(theme, style ~ ".Focus", part);
    }

    return renderData;
}

void onProgress() {
}

void render(in RenderEvent event, in Theme theme, RenderData renderData) {
    renderStatefulTextureHorizontalChain(
        theme,
        event,
        renderData.background,
        renderData.measure.backgroundPosition,
        renderData.measure.backgroundSize,
        State.leave,
        Widget.PartDraws.center
    );
}

RenderDataMeasure updateRenderDataMeasure(Button widget) {
    RenderDataMeasure measure;

    measure.backgroundPosition = widget.absolutePosition;
    measure.backgroundSize = widget.size;

    return measure;
}

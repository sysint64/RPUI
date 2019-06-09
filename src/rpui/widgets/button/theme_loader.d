module rpui.widgets.button.theme_loader;

import rpdl;

import rpui.theme;
import rpui.primitives;
import rpui.render.components;
import rpui.render.components_factory;
import rpui.widgets.button;
import rpui.widgets.button.render_system;

import gapi.geometry;

struct ButtonThemeLoader {
    Button.Measure readMeasure(RpdlNode data, in string style) {
        const focusKey = style ~ ".Focus";

        Button.Measure measure = {
            focusOffsets: data.getVec2f(focusKey ~ ".offsets.0"),
            focusResize: data.getNumber(focusKey ~ ".offsets.1"),
            textLeftMargin: data.getNumber(style ~ ".textLeftMargin.0"),
            textRightMargin: data.getNumber(style ~ ".textRightMargin.0"),
            iconGaps: data.getNumber(style ~ ".iconGaps.0"),
            iconOffsets: data.getVec2f(style ~ ".iconOffsets")
        };
        return measure;
    }

    RenderData loadRenderData(Theme theme, in string style) {
        RenderData renderData;

        renderData.background = createStatefulChainFromRdpl(theme, Orientation.horizontal, style);
        renderData.focusGlow = createChainFromRdpl(theme, Orientation.horizontal, style ~ ".Focus");
        renderData.captionText = createStatefulUiText(theme, style, "Text");

        return renderData;
    }
}

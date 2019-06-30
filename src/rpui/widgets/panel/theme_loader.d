module rpui.widgets.panel.theme_loader;

import rpdl;

import rpui.theme;
import rpui.primitives;
import rpui.render.components;
import rpui.render.components_factory;
import rpui.widgets.panel.widget;
import rpui.widgets.panel.render_system;

import gapi.geometry;

struct PanelThemeLoader {
    Panel.Measure createMeasureFromRpdl(RpdlNode data, in string style) {
        Panel.Measure measure = {
            scrollButtonMinSize: data.getNumber(style ~ ".Scroll.buttonMinSize.0"),
            horizontalScrollRegionWidth: data.getNumber(style ~ ".Scroll.Horizontal.regionWidth.0"),
            verticalScrollRegionWidth: data.getNumber(style ~ ".Scroll.Vertical.regionWidth.0"),
            headerHeight: data.getNumber(style ~ ".Header.height.0"),
            splitThickness: data.getNumber(style ~ ".Split.thickness.0"),
        };
        return measure;
    }

    RenderData loadRenderData(Theme theme, in string style) {
        RenderData renderData;
        RpdlNode data = theme.tree.data;

        with (renderData) {
            backgroundColors = [
                Panel.Background.light: data.getNormColor(style ~ ".backgroundLight"),
                Panel.Background.dark: data.getNormColor(style ~ ".backgroundDark"),
                Panel.Background.action: data.getNormColor(style ~ ".backgroundAction"),
            ];
            splitColors = [
                SplitColor.darkInner: data.getNormColor(style ~ ".Split.Dark.innerColor"),
                SplitColor.darkOuter: data.getNormColor(style ~ ".Split.Dark.outerColor"),
                SplitColor.lightInner: data.getNormColor(style ~ ".Split.Light.innerColor"),
                SplitColor.lightOuter: data.getNormColor(style ~ ".Split.Light.outerColor"),
            ];
            background = createGeometry();
            splitInner = createGeometry();
            splitOuter = createGeometry();
            headerBackground = createStatefulTexAtlasTextureQuadFromRdpl(
                theme,
                style ~ ".Header", "background",
                [State.leave, State.enter]
            );
            headerText = createStatefulUiTextFromRdpl(
                theme,
                style ~ ".Header", "Text",
                [State.leave, State.enter]
            );
            headerMarkSize = data.getVec2f(style ~ ".Header.Mark.size");
            headerMarkPosition = data.getVec2f(style ~ ".Header.Mark.position");
            headerMark = createUiSkinTextureQuad(theme);
            headerOpenMarkTexCoords = createNormilizedTextureCoordsFromRdpl(
                theme,
                style ~ ".Header.Mark.open"
            );
            headerCloseMarkTexCoords = createNormilizedTextureCoordsFromRdpl(
                theme,
                style ~ ".Header.Mark.close"
            );
            horizontalScrollButton = createStatefulChainFromRdpl(
                theme,
                Orientation.horizontal,
                style ~ ".Scroll.Horizontal.Button"
            );
            verticalScrollButton = createStatefulChainFromRdpl(
                theme,
                Orientation.vertical,
                style ~ ".Scroll.Vertical.Button"
            );
        }

        return renderData;
    }
}

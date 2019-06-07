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

import rpui.widgets.panel.transforms_system;
import rpui.widgets.panel.render_system;

import gapi.texture;

class PanelRenderer : Renderer {
    Panel widget;
    Theme theme;
    RenderData renderData;
    RenderTransforms transforms;
    string style;

    TransformSystem transformSystem;
    RenderSystem renderSystem;

    override void onCreate(Widget widget) {
        this.widget = cast(Panel) widget;
        this.theme = widget.view.theme;
        this.style = widget.style;

        with (theme.tree) {
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
                headerText = createStatefulUiText(
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
        }
    }

    override void onRender() {
        renderSystem.onRender(widget, &renderData, &transforms);
    }

    override void onProgress() {
        transforms = transformSystem.onProgress(widget, &renderData);
    }
}

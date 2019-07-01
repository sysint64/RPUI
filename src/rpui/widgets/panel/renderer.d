module rpui.widgets.panel.renderer;

import rpui.events;
import rpui.theme;
import rpui.math;
import rpui.widget;
import rpui.widgets.panel.widget;
import rpui.render.components;
import rpui.render.components_factory;
import rpui.render.transforms;
import rpui.render.renderer;
import rpui.primitives;

import rpui.widgets.panel.transforms_system;
import rpui.widgets.panel.render_system;

import gapi.texture;

final class PanelRenderer : Renderer {
    Panel widget;
    Theme theme;
    RenderData renderData;
    RenderTransforms transforms;
    string style;

    TransformsSystem transformsSystem;
    RenderSystem renderSystem;

    override void onCreate(Widget widget, in string style) {
        this.widget = cast(Panel) widget;
        this.theme = widget.view.theme;
        this.style = style;
        this.renderData = this.widget.themeLoader.loadRenderData(theme, style);

        renderSystem = new PanelRenderSystem(this.widget, &renderData, &transforms);
        transformsSystem = new PanelTransformsSystem(this.widget, &renderData, &transforms);
    }

    override void onRender() {
        renderSystem.onRender();
    }

    override void onProgress(in ProgressEvent event) {
        transformsSystem.onProgress(event);
    }
}

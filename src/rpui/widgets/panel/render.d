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

final class PanelRenderer : Renderer {
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
        this.renderData = this.widget.themeLoader.loadRenderData(theme, style);
    }

    override void onRender() {
        renderSystem.onRender(widget, &renderData, &transforms);
    }

    override void onProgress() {
        transforms = transformSystem.onProgress(widget, &renderData);
    }
}

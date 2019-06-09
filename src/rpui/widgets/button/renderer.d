module rpui.widgets.button.renderer;

import rpui.events;
import rpui.theme;
import rpui.widget;
import rpui.render.transforms;
import rpui.render.renderer;
import rpui.widgets.button;
import rpui.widgets.button.transforms_system;
import rpui.widgets.button.render_system;

final class ButtonRenderer : Renderer {
    Button widget;
    Theme theme;
    RenderData renderData;
    RenderTransforms transforms;
    string style;

    TransformsSystem transformSystem;
    RenderSystem renderSystem;

    override void onCreate(Widget widget) {
        this.widget = cast(Button) widget;
        this.theme = widget.view.theme;
        this.style = widget.style;
        this.renderData = this.widget.themeLoader.loadRenderData(theme, style);

        renderSystem = new ButtonRenderSystem(this.widget, &renderData, &transforms);
        transformSystem = new ButtonTransformsSystem(this.widget, &renderData, &transforms);
    }

    override void onRender() {
        renderSystem.onRender();
    }

    override void onProgress(in ProgressEvent event) {
        transformSystem.onProgress(event);
    }
}

module rpui.widgets.dialog.renderer;

import rpui.theme;
import rpui.events;
import rpui.widget;
import rpui.widgets.panel.renderer;
import rpui.widgets.dialog.widget;
import rpui.render.components;
import rpui.render.components_factory;
import rpui.render.renderer;
import rpui.render.transforms;

final class DialogRenderer : Renderer {
    private Dialog widget;
    private Theme theme;

    private Block background;
    private BlockTransforms backgroundTransforms;

    override void onCreate(Widget widget, in string style) {
        this.theme = widget.view.theme;
        this.widget = cast(Dialog) widget;
        this.background = createBlockFromRdpl(theme, style);
    }

    override void onRender() {
        renderBlock(theme, background, backgroundTransforms);
    }

    override void onProgress(in ProgressEvent event) {
        backgroundTransforms = updateBlockTransforms(
            background.widths,
            background.heights,
            widget.view.cameraView,
            widget.absolutePosition,
            widget.size
        );

        import std.stdio;
        writeln(widget.size);
    }
}

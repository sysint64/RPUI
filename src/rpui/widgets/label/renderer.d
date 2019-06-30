module rpui.widgets.label.renderer;

import rpui.theme;
import rpui.events;
import rpui.widget;
import rpui.widgets.label.widget;
import rpui.render.components;
import rpui.render.components_factory;
import rpui.render.renderer;
import rpui.render.transforms;

final class LabelRenderer : Renderer {
    private UiText text;
    private UiTextTransforms textTransforms;
    private Label widget;
    private Theme theme;

    override void onCreate(Widget widget) {
        this.theme = widget.view.theme;
        this.widget = cast(Label) widget;

        text = createUiTextFromRdpl(theme, widget.style, "Regular");
    }

    override void onRender() {
        renderUiText(theme, text.render, text.attrs, textTransforms);
    }

    override void onProgress(in ProgressEvent event) {
        with (text.attrs) {
            caption = widget.caption;
            textAlign = widget.textAlign;
            textVerticalAlign = widget.textVerticalAlign;
        }

        textTransforms = updateUiTextTransforms(
            &text.render,
            &theme.regularFont,
            textTransforms,
            text.attrs,
            widget.view.cameraView,
            widget.absolutePosition + widget.innerOffsetStart,
            widget.size
        );

        widget.measure.textWidth = textTransforms.size.x;
        widget.measure.lineHeight = textTransforms.size.y;
    }
}

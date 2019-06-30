module rpui.widgets.tab_button.renderer;

import rpui.events;
import rpui.widget;
import rpui.widgets.button.renderer;
import rpui.widgets.tab_button.widget;

final class TabButtonRenderer : ButtonRenderer {
    private TabButton widget;

    override void onCreate(Widget widget) {
        super.onCreate(widget);
        this.widget = cast(TabButton) widget;
    }

    override void onProgress(in ProgressEvent event) {
        super.onProgress(event);

        renderData.textVisible = (widget.hideCaptionWhenUnchecked && widget.checked) ||
            !widget.hideCaptionWhenUnchecked;

        if (!renderData.textVisible) {
            widget.measure.textWidth = 0;
        }
    }
}

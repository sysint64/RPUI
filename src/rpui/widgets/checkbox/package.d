module rpui.widgets.checkbox;

import rpui.events;
import rpui.input;
import rpui.math;
import rpui.primitives;
import rpui.widget;
import rpui.widgets.checkbox.renderer;

class Checkbox : Widget {
    @field Align textAlign = Align.left;
    @field VerticalAlign textVerticalAlign = VerticalAlign.middle;
    @field utf32string caption = "Checkbox";
    @field bool checked = false;

    package struct Measure {
        float lineHeight;
        float textWidth;
    }

    package Measure measure;

    this(in string style = "Checkbox") {
        super(style);
        this.drawChildren = false;
        this.renderer = new CheckboxRenderer();
    }

    override void onProgress(in ProgressEvent event) {
        locator.updateAbsolutePosition();
        locator.updateLocationAlign();
        locator.updateVerticalLocationAlign();
        updateSize();
        renderer.onProgress(event);
    }

protected:
    override void onCreate() {
        super.onCreate();
        focusable = false;
    }

    override void updateSize() {
        super.updateSize();

        if (heightType == SizeType.wrapContent) {
            size.y = measure.lineHeight + innerOffsetSize.y;
        }

        if (widthType == SizeType.wrapContent) {
            size.x = measure.textWidth + innerOffsetSize.x;
        }
    }

    override void onMouseDown(in MouseDownEvent event) {
        super.onMouseDown(event);

        if (isEnter) {
            checked = !checked;
        }
    }
}

module rpui.widgets.label.widget;

import rpui.events;
import rpui.input;
import rpui.math;
import rpui.primitives;
import rpui.widget;
import rpui.widgets.label.renderer;

class Label : Widget {
    @field Align textAlign = Align.left;
    @field VerticalAlign textVerticalAlign = VerticalAlign.middle;
    @field float lineHeightFactor = 1.5;
    @field utf32string caption = "Label";

    package struct Measure {
        float lineHeight;
        float textWidth;
    }

    package Measure measure;

    this(in string style = "Label") {
        super(style);
        this.drawChildren = false;
        this.renderer = new LabelRenderer();
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
            size.y = measure.lineHeight * lineHeightFactor + innerOffsetSize.y;
        }

        if (widthType == SizeType.wrapContent) {
            size.x = measure.textWidth + innerOffsetSize.x;
        }
    }
}

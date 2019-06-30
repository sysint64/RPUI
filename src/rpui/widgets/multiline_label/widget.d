module rpui.widgets.multiline_label.widget;

import rpui.events;
import rpui.input;
import rpui.math;
import rpui.primitives;
import rpui.widget;
import rpui.widgets.multiline_label.renderer;

class MultilineLabel : Widget {
    @field Align textAlign = Align.left;
    @field VerticalAlign textVerticalAlign = VerticalAlign.middle;
    @field float lineHeightFactor = 1;
    @field utf32string caption = "Label";

    package struct Measure {
        float lineHeight;
        float maxLineWidth;
        size_t linesCount;
    }

    package Measure measure;

    this(in string style = "Label") {
        super(style);
        this.drawChildren = false;
        this.renderer = new MultilineLabelRenderer();
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
            const textLineHeight = measure.lineHeight * lineHeightFactor;
            const boundaryHeight = textLineHeight * measure.linesCount;
            size.y = boundaryHeight + innerOffsetSize.y;
        }

        if (widthType == SizeType.wrapContent) {
            size.x = measure.maxLineWidth + innerOffsetSize.x;
        }
    }
}

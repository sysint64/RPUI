module rpui.widgets.button.widget;

import std.container.array;

import rpui.math;
import rpui.primitives;
import rpui.widget;
import rpui.view;
import rpui.events;
import rpui.render.renderer;
import rpui.widgets.button.renderer;
import rpui.widgets.button.theme_loader;

class Button : Widget {
    @field bool allowCheck = false;
    @field Align textAlign = Align.center;
    @field VerticalAlign textVerticalAlign = VerticalAlign.middle;
    @field Array!string icons;
    @field utf32string caption = "Button";
    @field int uselessIconArea = 0;

    struct Measure {
        float textWidth = 0;
        vec2 focusOffsets;
        float focusResize;
        float textLeftMargin;
        float textRightMargin;
        float iconGaps;
        vec2 iconOffsets;
        float iconsAreaSize = 0;
    }

    package string iconsGroup;
    public Measure measure;
    package ButtonThemeLoader themeLoader;

    this(in string style = "Button", in string iconsGroup = "icons") {
        super(style);

        this.drawChildren = false;
        this.iconsGroup = iconsGroup;

        // TODO: rm hardcode
        size = vec2(50, 21);
        widthType = SizeType.wrapContent;
        renderer = new ButtonRenderer();
    }

    override void onProgress(in ProgressEvent event) {
        locator.updateLocationAlign();
        locator.updateVerticalLocationAlign();
        locator.updateAbsolutePosition();
        locator.updateRegionAlign();
        updateSize();
        renderer.onProgress(event);
    }

    override void updateSize() {
        super.updateSize();

        if (widthType == SizeType.wrapContent) {
            if (!icons.empty) {
                size.x = measure.iconsAreaSize + measure.iconGaps + measure.iconOffsets.x * 2;
            } else {
                size.x = measure.textLeftMargin + measure.textRightMargin;
            }

            if (measure.textWidth != 0f) {
                size.x += measure.textWidth;

                if (!icons.empty) {
                    size.x += measure.textLeftMargin;
                }
            }
        }
    }

    protected override void onCreate() {
        super.onCreate();
        measure = themeLoader.readMeasure(view.theme.tree.data, style);
    }
}

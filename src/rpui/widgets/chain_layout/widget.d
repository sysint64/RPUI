module rpui.widgets.chain_layout.widget;

import std.math;

import rpui.events;
import rpui.primitives;
import rpui.math;
import rpui.widget;
import rpui.widgets.stack_layout.stack_locator;
import rpui.widgets.chain_layout.renderer;

class ChainLayout : Widget {
    private StackLocator stackLocator;

    this(in string style = "ChainLayout") {
        super(style);

        skipFocus = true;
        stackLocator.attach(this);
        stackLocator.orientation = Orientation.horizontal;
        renderer = new ChainLayoutRenderer();
    }

    override void onProgress(in ProgressEvent event) {
        super.onProgress(event);

        locator.updateLocationAlign();
        locator.updateVerticalLocationAlign();
        locator.updateRegionAlign();
        locator.updateAbsolutePosition();

        updateSize();

        foreach (Widget widget; children) {
            updatePartDraws(widget, PartDraws.center);
        }

        updatePartDraws(children.front, PartDraws.left);
        updatePartDraws(children.back, PartDraws.right);

        // little adjustment.
        // TODO(Andrey): explay meaning of number 1
        children.back.associatedWidget.margin.left = 1;
    }

    override void updateSize() {
        super.updateSize();

        handleWidgetsVariableSize();
        stackLocator.updateWidgetsPosition();
        stackLocator.updateSize();
    }

    private void handleWidgetsVariableSize() {
        float fixedSize = 0;
        int nonFixedCount = 0;

        if (widthType == SizeType.matchParent) {
            locationAlign = Align.none;
            size.x = parent.innerSize.x - outerOffsetSize.x;
            position.x = 0;
        }

        foreach (Widget row; children) {
            const widget = row.associatedWidget;

            if (widget.widthType != SizeType.matchParent) {
                fixedSize += widget.size.x;
            } else {
                nonFixedCount += 1;
            }
        }

        const partWidth = round((size.x - fixedSize) / nonFixedCount);

        float total = 0;
        Widget lastNonFixedWidget = null;

        foreach (Widget row; children) {
            Widget widget = row.associatedWidget;

            if (widget.widthType == SizeType.matchParent) {
                widget.size.x = partWidth;
                lastNonFixedWidget = widget;
            }

            total += widget.width;
        }

        // NOTE(Andrey): Adjustment because of partWidth rounding.
        if (lastNonFixedWidget !is null) {
            lastNonFixedWidget.size.x += size.x - total - 1;
        }
    }

    private void updatePartDraws(Widget row, in Widget.PartDraws partDraws) {
        row.associatedWidget.partDraws = partDraws;
    }

    override void onRender() {
        renderer.onRender();
    }
}

/**
 * Copyright: © 2018 Andrey Kabylin
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 */

module rpui.widgets.chain_layout;

import std.math;

import basic_types;
import gapi;
import math.linalg;

import rpui.widgets.stack_locator;
import rpui.widget;
import rpui.render_objects;

class ChainLayout : Widget {
    private BaseRenderObject splitRenderObject;
    private vec2 splitOffset;
    private vec4 background = vec4(0, 0, 0, 1);
    private StackLocator stackLocator;

    this(in string style = "ChainLayout") {
        super(style);

        stackLocator.attach(this);
        stackLocator.orientation = Orientation.horizontal;
    }

    override void onCreate() {
        super.onCreate();
        splitRenderObject = renderFactory.createQuad(style ~ ".split");

        with (manager.theme.tree) {
            splitOffset = data.getVec2f(style ~ ".splitOffset");
        }
    }

    override void progress() {
        super.progress();

        locator.updateAbsolutePosition();
        locator.updateRegionAlign();
        updateSize();

        foreach (Widget widget; children) {
            updatePartDraws(widget, PartDraws.center);
        }

        updatePartDraws(children.front, PartDraws.left);
        updatePartDraws(children.back, PartDraws.right);
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

        // Adjustment because of partWidth rounding.
        if (lastNonFixedWidget !is null) {
            lastNonFixedWidget.size.x += size.x - total;
        }
    }

    override void render(Camera camera) {
        super.render(camera);
        float splitPos = 0;

        foreach (Widget widget; children) {
            if (children.back == widget)
                continue;

            splitPos += widget.associatedWidget.width;
            renderer.renderQuad(splitRenderObject, absolutePosition + vec2(splitPos, 0) + splitOffset);
        }
    }

    private void updatePartDraws(Widget row, in Widget.PartDraws partDraws) {
        row.associatedWidget.partDraws = partDraws;
    }
}

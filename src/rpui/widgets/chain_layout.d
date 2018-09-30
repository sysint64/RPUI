/**
 * Copyright: © 2018 Andrey Kabylin
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 */

module rpui.widgets.chain_layout;

import basic_types;
import gapi;
import math.linalg;

import rpui.widgets.stack_layout;
import rpui.widget;
import rpui.render_objects;

class ChainLayout : StackLayout {
    private BaseRenderObject splitRenderObject;
    private vec2 splitOffset;

    this(in string style = "ChainLayout") {
        super(style);
    }

    override void onCreate() {
        super.onCreate();

        widthType = SizeType.wrapContent;
        heightType = SizeType.wrapContent;
        orientation = Orientation.horizontal;
        splitRenderObject = renderFactory.createQuad(style ~ ".split");
    }

    override void progress() {
        super.progress();

        foreach (Widget widget; children) {
            updatePartDraws(widget, Widget.PartDraws.center);
        }

        updatePartDraws(children.front, Widget.PartDraws.left);
        updatePartDraws(children.back, Widget.PartDraws.right);
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

        with (manager.theme.tree) {
            splitOffset = data.getVec2f(style ~ ".splitOffset");
        }
    }
}

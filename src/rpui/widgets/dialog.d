/**
 * Copyright: © 2017 Andrey Kabylin
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 */

module rpui.widgets.dialog;

import basic_types;
import gapi;
import basic_rpdl_extensions;

import rpui.render_objects;
import rpui.widget;
import rpui.widgets.panel;
import rpui.events;

final class Dialog : Widget {
    @Field utf32string caption = "Dialog";
    @Field bool closeOnClickOutsideArea = false;
    @Field bool draggable = false;
    @Field bool resizable = false;

    private BaseRenderObject[string] blockRenderObjects;

    private bool isHeaderClick = false;

    this(in string style = "Dialog") {
        super(style);
        skipFocus = true;
        finalFocus = true;
    }

    override void render(Camera camera) {
        renderer.renderBlock(blockRenderObjects, absolutePosition, size);
        super.render(camera);
    }

    protected override void onCreate() {
        super.onCreate();

        visible = false;
        renderFactory.createBlock(blockRenderObjects, style);

        with (manager.theme.tree) {
            extraInnerOffset = data.getFrameRect(style ~ ".extraInnerOffset");
            extraInnerOffset.top += data.getNumber(style ~ ".headerHeight.0");

            const gaps = data.getFrameRect(style ~ ".gaps");

            extraInnerOffset.left += gaps.left;
            extraInnerOffset.top += gaps.top;
            extraInnerOffset.right += gaps.right;
            extraInnerOffset.bottom += gaps.bottom;
        }
    }

    override void updateSize() {
        super.updateSize();

        if (heightType == SizeType.wrapContent) {
            size.y = innerBoundarySize.y;
        }

        if (widthType == SizeType.wrapContent) {
            size.x = innerBoundarySize.x;
        }
    }

    override void onMouseDown(in MouseDownEvent event) {
        if (!isOver && closeOnClickOutsideArea && visible) {
            close();
        } else {
            super.onMouseDown(event);
        }
    }

    void open() {
        visible = true;
        freezeUI(false);
        focusNavigator.focusPrimary();
    }

    void close() {
        visible = false;
        unfreezeUI();
    }
}

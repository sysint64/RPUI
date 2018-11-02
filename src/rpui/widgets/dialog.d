/**
 * Copyright: © 2017 Andrey Kabylin
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 */

module rpui.widgets.dialog;

import basic_types;
import gapi;

import rpui.render_objects;
import rpui.widget;

final class Dialog : Widget {
    @Field
    utf32string caption = "Dialog";

    private BaseRenderObject[string] blockRenderObjects;

    private bool isHeaderClick = false;

    this(in string style = "Dialog") {
        super(style);
    }

    override void render(Camera camera) {
        super.render(camera);
        renderer.renderBlock(blockRenderObjects, absolutePosition, size);
    }

    protected override void onCreate() {
        super.onCreate();
        renderFactory.createBlock(blockRenderObjects, style);
    }
}

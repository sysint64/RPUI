/**
 * Copyright: © 2017 RedGoosePaws
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 * Authors: Andrey Kabylin
 */

module rpui.widgets.label;

import input;
import math.linalg;
import basic_types;

import gapi;

import rpui.widget;
import rpui.manager;
import rpui.render_objects;

class Label : Widget {
    @Field Align textAlign = Align.left;
    @Field VerticalAlign textVerticalAlign = VerticalAlign.middle;

    private utfstring p_caption = "Label";

    @Field
    @property void caption(utfstring value) {
        if (manager is null) {
            p_caption = value;
        } else {
            p_caption = value;
            textRenderObject.text = value;
        }
    }

    @property utfstring caption() { return p_caption; }

    this() {
        super("Label");
        this.drawChildren = false;
    }

    this(in string style) {
        super(style);
        this.drawChildren = false;
    }

    override void onProgress() {
        updateAbsolutePosition();
        updateLocationAlign();
        updateVerticalLocationAlign();
    }

    override void render(Camera camera) {
        super.render(camera);

        textRenderObject.textAlign = textAlign;
        textRenderObject.textVerticalAlign = textVerticalAlign;
        renderer.renderText(textRenderObject, "Regular", absolutePosition, size);
    }

private:
    TextRenderObject textRenderObject;

protected:
    override void onCreate() {
        super.onCreate();

        textRenderObject = renderFactory.createText(style, "Regular");
        textRenderObject.text = caption;

        focusable = false;
    }
}

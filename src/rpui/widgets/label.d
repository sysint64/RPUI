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
    @Field float lineHeightFactor = 1.5;

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

    override void progress() {
        locator.updateAbsolutePosition();
        locator.updateLocationAlign();
        locator.updateVerticalLocationAlign();
        updateSize();
    }

    override void render(Camera camera) {
        super.render(camera);

        textRenderObject.textAlign = textAlign;
        textRenderObject.textVerticalAlign = textVerticalAlign;

        const textPos = absolutePosition + innerOffsetStart;
        renderer.renderText(textRenderObject, "Regular", textPos, size);
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

    override void updateSize() {
        super.updateSize();

        if (heightType == SizeType.wrapContent) {
            size.y = textRenderObject.lineHeight * lineHeightFactor + innerOffsetSize.y;
        }

        if (widthType == SizeType.wrapContent) {
            size.x = textRenderObject.textWidth + innerOffsetSize.x;
        }
    }
}

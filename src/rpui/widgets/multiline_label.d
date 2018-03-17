/**
 * Copyright: © 2017 RedGoosePaws
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 * Authors: Andrey Kabylin
 */

module rpui.widgets.multiline_label;

import std.container.array;
import std.string;
import std.array : array;
import std.math;

import input;
import math.linalg;
import basic_types;

import gapi;

import rpui.widget;
import rpui.manager;
import rpui.render_objects;

class MultilineLabel : Widget {
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
            recreateTextRenderObjects();
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

        const textLineHeight = lineHeight * lineHeightFactor;
        const boundaryHeight = textLineHeight * textRenderObjects.length;
        float textCurrentPosY = absolutePosition.y;

        switch (textVerticalAlign) {
            case VerticalAlign.bottom:
                textCurrentPosY += size.y - boundaryHeight - innerOffsetEnd.y;
                break;

            case VerticalAlign.middle:
                textCurrentPosY += round((size.y - boundaryHeight) * 0.5);
                break;

            default:
                textCurrentPosY += innerOffsetStart.y;
                break;
        }

        foreach (textRenderObject; textRenderObjects) {
            textRenderObject.textAlign = textAlign;
            textRenderObject.textVerticalAlign = VerticalAlign.middle;

            const textPos = vec2(innerOffsetStart.x + absolutePosition.x, textCurrentPosY);
            const textSizeY = textLineHeight;
            const textSize = vec2(size.x - innerOffsetSize.x, textSizeY);

            renderer.renderText(textRenderObject, "Regular", textPos, textSize);
            textCurrentPosY += textSizeY;
        }
    }

private:
    Array!TextRenderObject textRenderObjects;
    float lineHeight = 1;

protected:
    void recreateTextRenderObjects() {
        textRenderObjects.clear();
        const lines = lineSplitter(p_caption).array;

        foreach (utfstring line; lines) {
            auto renderObject = renderFactory.createText(style, "Regular");
            renderObject.text = line;
            lineHeight = renderObject.lineHeight;
            textRenderObjects.insert(renderObject);
        }
    }

    override void onCreate() {
        super.onCreate();
        recreateTextRenderObjects();
        focusable = false;
    }

    override void updateSize() {
        super.updateSize();

        if (heightType == SizeType.wrapContent) {
            const textLineHeight = lineHeight * lineHeightFactor;
            const boundaryHeight = textLineHeight * textRenderObjects.length;
            size.y = boundaryHeight + innerOffsetSize.y;
        }

        if (widthType == SizeType.wrapContent) {
            float maxLineWidth = 0;

            foreach (renderObject; textRenderObjects) {
                if (maxLineWidth < renderObject.textWidth) {
                    maxLineWidth = renderObject.textWidth;
                }
            }

            size.x = maxLineWidth + innerOffsetSize.x;
        }
    }
}

/**
 * Copyright: © 2017 Andrey Kabylin
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 */

module rpui.widgets.checkbox;

import input;
import math.linalg;
import basic_types;

import gapi;

import rpui.widget;
import rpui.manager;
import rpui.render_objects;
import rpui.events;

class Checkbox : Widget {
    @Field Align textAlign = Align.left;
    @Field VerticalAlign textVerticalAlign = VerticalAlign.middle;
    @Field bool checked = false;

    private utf32string p_caption = "Checkbox";

    @Field
    @property void caption(utf32string value) {
        if (manager is null) {
            p_caption = value;
        } else {
            p_caption = value;
            textRenderObject.text = value;
        }
    }

    @property utf32string caption() { return p_caption; }

    this() {
        super("Checkbox");
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
    }

    override void render(Camera camera) {
        super.render(camera);

        // Box
        renderer.renderQuad(boxRenderObject, checkboxState, absolutePosition);

        // Text
        textRenderObject.textAlign = textAlign;
        textRenderObject.textVerticalAlign = textVerticalAlign;
        renderer.renderText(textRenderObject, checkboxState, absolutePosition, size);

        // Focus glow
        if (isFocused) {
            const focusPos = absolutePosition + focusOffsets;
            renderer.renderQuad(focusRenderObject, "Focus", focusPos);
        }
    }

    override void onMouseDown(in MouseDownEvent event) {
        super.onMouseDown(event);

        if (isEnter) {
            checked = !checked;
        }
    }

private:
    vec2 focusOffsets;

    BaseRenderObject boxRenderObject;
    BaseRenderObject focusRenderObject;
    TextRenderObject textRenderObject;

protected:
    override void onClickActionInvoked() {
        checked = !checked;
    }

    @property string checkboxState() {
        const boxState = state == "Enter" || state == "Click" ? "Enter" : "Leave";
        const checkedState = checked ? "Checked" : "Unchecked";
        return checkedState ~ "." ~ boxState;
    }

    override void onCreate() {
        super.onCreate();

        const states = ["Checked.Leave", "Checked.Enter",
                        "Unchecked.Leave", "Unchecked.Enter"];

        renderFactory.createQuad(boxRenderObject, style, states, "element");
        renderFactory.createQuad(focusRenderObject, style, "Focus", "element");

        with (manager.theme.tree) {
            focusOffsets = data.getVec2f(style ~ ".Focus.offsets");
        }

        textRenderObject = renderFactory.createText(style, states);
        textRenderObject.text = caption;
    }
}

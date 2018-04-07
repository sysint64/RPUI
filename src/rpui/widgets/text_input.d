module rpui.widgets.text_input;

import basic_types;

import gapi;
import math.linalg;

import rpui.widget;
import rpui.manager;
import rpui.render_objects;
import rpui.cursor;

class TextInput : Widget {
    enum InputType { text, integer, number }

    @Field Align textAlign = Align.center;
    @Field InputType inputType = InputType.text;

    private utfstring p_text = "TextInput";

    this(in string style = "TextInput") {
        super(style);

        this.drawChildren = false;
        this.cursor = Cursor.Icon.iBeam;

        // TODO: rm hardcode
        size = vec2(50, 21);
    }

    override void progress() {
        locator.updateAbsolutePosition();
        locator.updateLocationAlign();
        locator.updateVerticalLocationAlign();
        locator.updateRegionAlign();
        updateSize();
    }

    override void render(Camera camera) {
        super.render(camera);

        drawBackground();
    }

    private void drawBackground() {
        renderer.renderHorizontalChain(skinRenderObjects, state, absolutePosition, size);

        if (isFocused) {
            const focusPos = absolutePosition + focusOffsets;
            const focusSize = size + vec2(focusResize, focusResize);

            renderer.renderHorizontalChain(skinFocusRenderObjects, "Focus", focusPos, focusSize);
        }
    }

    protected override void onCreate() {
        super.onCreate();

        const states = ["Leave", "Enter", "Click"];
        const keys = ["left", "center", "right"];

        foreach (string key; keys) {
            renderFactory.createQuad(skinRenderObjects, style, states, key);
            renderFactory.createQuad(skinFocusRenderObjects, style, "Focus", key);
        }

        const focusKey = style ~ ".Focus";

        with (manager.theme.tree) {
            focusOffsets = data.getVec2f(focusKey ~ ".offsets.0");
            focusResize = data.getNumber(focusKey ~ ".offsets.1");
        }
    }

private:
    BaseRenderObject[string] skinRenderObjects;
    BaseRenderObject[string] skinFocusRenderObjects;
    TextRenderObject textRenderObject;

    vec2 focusOffsets;
    float focusResize;

    const splitChars = " ,.;:?'!|/\\~*+-=(){}<>[]#%&^@$№`\""d;
}

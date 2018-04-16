module rpui.widgets.text_input;

import basic_types;

import gapi;
import math.linalg;
import std.algorithm.comparison;

import rpui.widget;
import rpui.manager;
import rpui.render_objects;
import rpui.cursor;
import rpui.events;

class TextInput : Widget {
    enum InputType { text, integer, number }

    @Field Align textAlign = Align.left;
    @Field InputType inputType = InputType.text;

    private utfstring p_text = "TextInput";

    @Field
    @property void text(utfstring value) {
        if (manager is null) {
            p_text = value;
        } else {
            p_text = value;
            textRenderObject.text = value;
        }
    }

    @property utfstring text() { return p_text; }

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
        drawCarriage();
        drawText();
    }

    private void drawBackground() {
        renderer.renderHorizontalChain(skinRenderObjects, state, absolutePosition, size);

        if (isFocused) {
            const focusPos = absolutePosition + focusOffsets;
            const focusSize = size + vec2(focusResize, focusResize);

            renderer.renderHorizontalChain(skinFocusRenderObjects, "Focus", focusPos, focusSize);
        }
    }

    private void drawCarriage() {
        if (!isFocused) {
            carriage.timer = 0;
            return;
        }

        if (carriage.visible) {
            const position = absolutePosition + vec2(textLeftMargin - carriageBoundary, 0);

            renderer.renderQuad(
                carriage.renderObject,
                position + getCarriageOffset()
            );
        }

        carriage.timer += app.deltaTime;

        if (carriage.timer >= carriage.blinkThreshold) {
            carriage.visible = !carriage.visible;
            carriage.timer = 0;
        }
    }

    vec2 getCarriageOffset() {
        return vec2(
            textRenderObject.getRegionTextWidth(0, carriage.pos),
            0
        );
    }

    private void drawText() {
        textRenderObject.textAlign = textAlign;
        // textRenderObject.textVerticalAlign = textVerticalAlign;

        auto textPosition = absolutePosition;

        if (textAlign == Align.left) {
            textPosition.x += textLeftMargin;
        }
        else if (textAlign == Align.right) {
            textPosition.x -= textRightMargin;
        }

        renderer.renderText(textRenderObject, state, textPosition, size);
    }

    protected override void onCreate() {
        super.onCreate();

        const states = ["Leave", "Enter", "Click"];
        const keys = ["left", "center", "right"];

        foreach (string key; keys) {
            renderFactory.createQuad(skinRenderObjects, style, states, key);
            renderFactory.createQuad(skinFocusRenderObjects, style, "Focus", key);
        }

        carriage.renderObject = renderFactory.createQuad(style ~ ".stick");
        renderFactory.createQuad(leftArrowRenderObject, style, states, "arrowLeft");
        renderFactory.createQuad(rightArrowRenderObject, style, states, "arrowRight");

        const focusKey = style ~ ".Focus";

        with (manager.theme.tree) {
            focusOffsets = data.getVec2f(focusKey ~ ".offsets.0");
            focusResize = data.getNumber(focusKey ~ ".offsets.1");

            textRenderObject = renderFactory.createText(style, states);
            textRenderObject.text = text;
            textLeftMargin = data.getNumber(style ~ ".textLeftMargin.0");
            textRightMargin = data.getNumber(style ~ ".textRightMargin.0");

            carriageBoundary = data.getNumber(style ~ ".carriageBoundary.0");
        }
    }

    private bool isCharAllowed(in utfchar ch) {
        const b1 = ch;
        const b2 = ch >> 8;

        // TODO: why? link!
        return (b2 != 0 || b1 >= 0x20) && b1 <= 0x7E;
    }

    override void onTextEntered(in TextEnteredEvent event) {
        if (!isFocused)
            return;

        carriage.timer = 0;
        carriage.visible = true;

        const charToPut = event.key;

        if (!isCharAllowed(charToPut))
            return;

        // Splitting text to two parts by carriage position

        const regionMin = min(selectRegion.start, selectRegion.end);
        const regionMax = max(selectRegion.start, selectRegion.end);

        utfstring leftPart;
        utfstring rightPart;

        if (regionMin == regionMax) {
            leftPart = text[0 .. carriage.pos];
            rightPart = text[carriage.pos .. $];
        } else {
            throw new Error("TODO");
        }

        text = leftPart ~ charToPut ~ rightPart;

        carriage.lastPos = carriage.pos;
        carriage.pos++;

        events.notify(ChangeEvent());
    }

    override void onKeyPressed(in KeyPressedEvent event) {
    }

private:
    BaseRenderObject[string] skinRenderObjects;
    BaseRenderObject[string] skinFocusRenderObjects;
    BaseRenderObject leftArrowRenderObject;
    BaseRenderObject rightArrowRenderObject;
    TextRenderObject textRenderObject;

    vec2 focusOffsets;
    float focusResize;
    float textLeftMargin;
    float textRightMargin;
    float carriageBoundary;

    struct Carriage {
        float timer = 0;
        int lastPos = 0;
        int pos = 0;
        bool visible = true;
        BaseRenderObject renderObject;
        const blinkThreshold = 500f;
    }

    struct SelectRegion {
        int start;
        int end;
    }

    Carriage carriage;
    SelectRegion selectRegion;

    const splitChars = " ,.;:?'!|/\\~*+-=(){}<>[]#%&^@$№`\""d;
}

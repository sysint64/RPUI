module rpui.widgets.text_input;

import basic_types;

import gapi;
import math.linalg;
import std.algorithm.comparison;
import input;

import rpui.widget;
import rpui.manager;
import rpui.render_objects;
import rpui.cursor;
import rpui.events;
import rpui.widgets.text_input.edit_component;
import rpui.widgets.text_input.select_component;
import rpui.widgets.text_input.number_input_type_component;

class TextInput : Widget {
    enum InputType { text, integer, number }

    @Field Align textAlign = Align.left;
    @Field InputType inputType = InputType.text;
    @Field bool autoSelectOnFocus = false;

    int integerStep = 1;
    float numberStep = 0.1;

    @Field
    @property void step(in float value) {
        if (inputType == InputType.integer) {
            integerStep = cast(int) value;
        }
        else if (inputType == InputType.number) {
            numberStep = value;
        }
    }

    @property float step() {
        if (inputType == InputType.integer) {
            return integerStep;
        } else {
            return numberStep;
        }
    }

    @Field
    @property void text(utfstring value) {
        editComponent.text = value;
    }

    @property utfstring text() { return editComponent.text; }

    this(in string style = "TextInput") {
        super(style);

        this.drawChildren = false;
        this.cursor = Cursor.Icon.iBeam;

        // TODO: rm hardcode
        size = vec2(50, 21);
    }

    override void progress() {
        editComponent.carriage.onProgress(app.deltaTime);
        updateCarriagePostion();
        updateScroll();
        locator.updateAbsolutePosition();
        locator.updateLocationAlign();
        locator.updateVerticalLocationAlign();
        locator.updateRegionAlign();
        updateSize();
    }

    override void render(Camera camera) {
        super.render(camera);

        if (!isFocused)
            editComponent.reset();

        drawBackground();

        pushScissor();
        drawText();
        drawSelectRegion();  // Overlay text
        drawSelectedText();
        manager.popScissor();

        if (inputType == InputType.integer || inputType == InputType.number) {
            textAlign = Align.center;
            drawArrows();
        }

        drawCarriage();
    }

    private void pushScissor() {
        Rect scissor;
        scissor.point = vec2(
            absolutePosition.x + textLeftMargin,
            absolutePosition.y
        );
        scissor.size = vec2(
            size.x - textLeftMargin - textRightMargin,
            size.y
        );

        manager.pushScissor(scissor);
    }

    private void drawBackground() {
        renderer.renderHorizontalChain(skinRenderObjects, state, absolutePosition, size);

        if (isFocused) {
            const focusPos = absolutePosition + focusOffsets;
            const focusSize = size + vec2(focusResize, focusResize);

            renderer.renderHorizontalChain(skinFocusRenderObjects, "Focus", focusPos, focusSize);
        }
    }

    void drawSelectRegion() {
        if (!editComponent.selectRegion.textIsSelected())
            return;

        with (editComponent) {
            const regionSize = getTextRegionSize(selectRegion.start, selectRegion.end);

            selectRegion.size = vec2(regionSize, selectRegionHeight);
            selectRegion.absolutePosition = absolutePosition +
                getTextRegionOffset(selectRegion.start) +
                selectRegionOffset;

            renderer.renderColoredObject(
                selectRegionRenderObject,
                selectColor,
                selectRegion.absolutePosition,
                selectRegion.size
            );
        }
    }

    private void drawSelectedText() {
        if (!editComponent.selectRegion.textIsSelected())
            return;

        const textPosition = getTextPosition();
        const scissor = Rect(
            editComponent.selectRegion.absolutePosition,
            editComponent.selectRegion.size
        );

        manager.pushScissor(scissor);

        selectedTextRenderObject.textAlign = textAlign;
        selectedTextRenderObject.text = editComponent.text;
        renderer.renderText(selectedTextRenderObject, getTextPosition(), size);

        manager.popScissor();
    }

    private void drawArrows() {
        renderer.renderQuad(
            leftArrowRenderObject,
            state,
            absolutePosition
        );
    }

    // TODO: dmd PR #8155
    package float getTextRegionSize(in int start, in int end)
    in {
        assert(start <= end);
    }
    do {
        if (start == end)
            return 0.0f;

        return cast(float) textRenderObject.getRegionTextWidth(start, end);
    }

    package vec2 getTextRegionOffset(in int charPos) {
        const regionSize = getTextRegionSize(0, charPos);
        const offset = vec2(
            regionSize + editComponent.scrollDelta,
            -cast(float)(textRenderObject.lineHeight) + textTopMargin
        );

        float alignOffset = 0;

        if (textAlign == Align.left) {
            alignOffset = textLeftMargin;
        }
        else if (textAlign == Align.right) {
            alignOffset = -textRightMargin;
        }

        return vec2(alignOffset - carriageBoundary, 0) +
            textRenderObject.getTextRelativePosition() + offset;
    }

    private void updateScroll() {
        if (textAlign == Align.center) {
            editComponent.scrollDelta = 0;
            return;
        }

        const rightBorder = absolutePosition.x + size.x - textRightMargin;
        const leftBorder = absolutePosition.x + textLeftMargin;
        const padding = textRightMargin + textLeftMargin;
        const regionOffset = getTextRegionSize(0, editComponent.carriage.pos);

        if (editComponent.carriage.absolutePosition.x > rightBorder) {
            editComponent.scrollDelta = -regionOffset + size.x - padding;
            updateCarriagePostion();
        }
        else if (editComponent.carriage.absolutePosition.x < leftBorder) {
            editComponent.scrollDelta = -regionOffset;
            updateCarriagePostion();
        }
    }

    private void updateCarriagePostion() {
        editComponent.carriage.absolutePosition = absolutePosition +
            getTextRegionOffset(editComponent.carriage.pos);
    }

    private void drawText() {
        textRenderObject.textAlign = textAlign;
        textRenderObject.text = editComponent.text;
        renderer.renderText(textRenderObject, state, getTextPosition(), size);
    }

    private void drawCarriage() {
        if (!isFocused())
            return;

        if (editComponent.carriage.visible)
            renderer.renderQuad(
                carriageRenderObject,
                editComponent.carriage.absolutePosition
            );
    }

    package vec2 getTextPosition() {
        auto textPosition = absolutePosition;

        if (textAlign == Align.left) {
            textPosition.x += textLeftMargin + editComponent.scrollDelta;
        }
        else if (textAlign == Align.right) {
            textPosition.x -= textRightMargin - editComponent.scrollDelta;
        }

        return textPosition;
    }

    protected override void onCreate() {
        super.onCreate();

        editComponent.carriage.bind(&editComponent);

        const states = ["Leave", "Enter", "Click"];
        const keys = ["left", "center", "right"];

        foreach (string key; keys) {
            renderFactory.createQuad(skinRenderObjects, style, states, key);
            renderFactory.createQuad(skinFocusRenderObjects, style, "Focus", key);
        }

        renderFactory.createQuad(selectRegionRenderObject);
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
            textTopMargin = data.getNumber(style ~ ".textTopMargin.0");

            carriageRenderObject = renderFactory.createQuad(style ~ ".stick");
            carriageBoundary = data.getNumber(style ~ ".carriageBoundary.0");

            selectColor = data.getNormColor(style ~ ".selectColor");
            selectRegionHeight = data.getNumber(style ~ ".selectRegionHeight.0");
            selectRegionOffset = data.getVec2f(style ~ ".selectRegionOffset");
            selectedTextColor = data.getNormColor(style ~ ".selectedTextColor");

            selectedTextRenderObject = renderFactory.createText();
            selectedTextRenderObject.color = selectedTextColor;
        }
    }

    override void onTextEntered(in TextEnteredEvent event) {
        if (!isFocused)
            return;

        if (editComponent.onTextEntered(event))
            events.notify(ChangeEvent());
    }

    override void onKeyPressed(in KeyPressedEvent event) {
        if (!isFocused)
            return;

        editComponent.onKeyPressed(event);
    }

private:
    BaseRenderObject[string] skinRenderObjects;
    BaseRenderObject[string] skinFocusRenderObjects;
    BaseRenderObject leftArrowRenderObject;
    BaseRenderObject rightArrowRenderObject;
    TextRenderObject textRenderObject;
    BaseRenderObject carriageRenderObject;
    TextRenderObject selectedTextRenderObject;
    BaseRenderObject selectRegionRenderObject;

    vec2 focusOffsets;
    float focusResize;
    float textLeftMargin;
    float textRightMargin;
    float textTopMargin;
    float carriageBoundary;

    vec4 selectColor;
    vec4 selectedTextColor;
    float selectRegionHeight;
    vec2 selectRegionOffset;

    EditComponent editComponent;
    NumberInputTypeComponent numberInputTypeComponent;
}

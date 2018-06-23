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
import rpui.widget_events;
import rpui.widgets.text_input.edit_component;
import rpui.widgets.text_input.select_component;
import rpui.widgets.text_input.number_input_type_component;
import rpui.widgets.text_input.render_data;

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

        if (isNumberMode()) {
            updateArrowAbsolutePositions();
            updateArrowStates();
        }

        locator.updateAbsolutePosition();
        locator.updateLocationAlign();
        locator.updateVerticalLocationAlign();
        locator.updateRegionAlign();
        updateSize();
    }

    override void updateSize() {
        super.updateSize();
        updateCarriagePostion();
    }

    override void onBlur(in BlurEvent event) {
        editComponent.reset();
    }

    override void onFocus(in FocusEvent event) {
        if (autoSelectOnFocus && !isFocused)
            editComponent.selectAll();
    }

    override void render(Camera camera) {
        super.render(camera);

        drawBackground();

        pushScissor();
        drawText();
        drawSelectRegion();  // Overlay text
        drawSelectedText();
        manager.popScissor();

        if (isNumberMode()) {
            textAlign = Align.center;
            drawArrows();
        }

        drawCarriage();
    }

    private bool isNumberMode() {
        return inputType == InputType.integer || inputType == InputType.number;
    }

    private void pushScissor() {
        Rect scissor;
        scissor.point = vec2(
            absolutePosition.x + renderData.textLeftMargin,
            absolutePosition.y
        );
        scissor.size = vec2(
            size.x - renderData.textLeftMargin - renderData.textRightMargin,
            size.y
        );

        manager.pushScissor(scissor);
    }

    private void drawBackground() {
        renderer.renderHorizontalChain(renderData.skinRenderObjects, state, absolutePosition, size);

        if (isFocused) {
            const focusPos = absolutePosition + renderData.focusOffsets;
            const focusSize = size + vec2(renderData.focusResize, renderData.focusResize);

            renderer.renderHorizontalChain(renderData.skinFocusRenderObjects, "Focus", focusPos, focusSize);
        }
    }

    void drawSelectRegion() {
        if (!editComponent.selectRegion.textIsSelected())
            return;

        with (editComponent) {
            const regionSize = getTextRegionSize(selectRegion.start, selectRegion.end);

            selectRegion.size = vec2(regionSize, renderData.selectRegionHeight);
            selectRegion.absolutePosition = absolutePosition +
                getTextRegionOffset(selectRegion.start) +
                renderData.selectRegionOffset;

            renderer.renderColoredObject(
                renderData.selectRegionRenderObject,
                renderData.selectColor,
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

        renderData.selectedTextRenderObject.textAlign = textAlign;
        renderData.selectedTextRenderObject.text = editComponent.text;
        renderer.renderText(renderData.selectedTextRenderObject, getTextPosition(), size);

        manager.popScissor();
    }

    private void drawArrows() {
        renderer.renderQuad(
            renderData.leftArrowRenderObject,
            numberInputTypeComponent.leftArrow.state,
            numberInputTypeComponent.leftArrow.absolutePosition
        );

        renderer.renderQuad(
            renderData.rightArrowRenderObject,
            numberInputTypeComponent.rightArrow.state,
            numberInputTypeComponent.rightArrow.absolutePosition
        );
    }

    private void updateArrowAbsolutePositions() {
        with (numberInputTypeComponent) {
            leftArrow.absolutePosition = absolutePosition + renderData.arrowOffsets;

            const rightArrowWidth = renderData
                .rightArrowRenderObject
                .getTextureSize(rightArrow.state).x;

            const rightArrowOffsets = vec2(
                size.x - rightArrowWidth - renderData.arrowOffsets.x,
                renderData.arrowOffsets.y
            );

            rightArrow.absolutePosition = absolutePosition + rightArrowOffsets;
        }
    }

    private void updateArrowStates() {
        with (numberInputTypeComponent) {
            const areaSize = vec2(renderData.arrowsAreaWidth, size.y);

            leftArrow.area = Rect(
                absolutePosition,
                areaSize
            );

            rightArrow.area = Rect(
                absolutePosition + vec2(size.x - areaSize.x, 0),
                areaSize
            );

            leftArrow.isEnter = pointInRect(app.mousePos, leftArrow.area);
            rightArrow.isEnter = pointInRect(app.mousePos, rightArrow.area);
        }
    }

    /// Change system cursor when mouse entering to arrows.
    override void onCursor() {
        if (numberInputTypeComponent.leftArrow.isEnter) {
            manager.cursor = Cursor.Icon.normal;
        }
        else if (numberInputTypeComponent.rightArrow.isEnter) {
            manager.cursor = Cursor.Icon.normal;
        }
    }

    private void updateScroll() {
        if (textAlign == Align.center) {
            editComponent.scrollDelta = 0;
            return;
        }

        const rightBorder = absolutePosition.x + size.x - renderData.textRightMargin;
        const leftBorder = absolutePosition.x + renderData.textLeftMargin;
        const padding = renderData.textRightMargin + renderData.textLeftMargin;
        const regionOffset = editComponent.getTextRegionSize(0, editComponent.carriage.pos);
        const textSize = cast(float) renderData.textRenderObject.textWidth;
        const minScroll = -textSize + size.x - padding;

        if (editComponent.scrollDelta <= minScroll)
            editComponent.scrollDelta = minScroll;

        if (textSize + padding < size.x) {
            editComponent.scrollDelta = 0;
        }
        else if (editComponent.carriage.absolutePosition.x > rightBorder) {
            editComponent.scrollDelta = -regionOffset + size.x - padding;
        }
        else if (editComponent.carriage.absolutePosition.x < leftBorder) {
            editComponent.scrollDelta = -regionOffset;
        }

        updateCarriagePostion();
    }

    private void updateCarriagePostion() {
        editComponent.carriage.absolutePosition = absolutePosition +
            editComponent.getTextRegionOffset(editComponent.carriage.pos);
    }

    private void drawText() {
        renderData.textRenderObject.textAlign = textAlign;
        renderData.textRenderObject.text = editComponent.text;
        renderer.renderText(renderData.textRenderObject, state, getTextPosition(), size);
    }

    private void drawCarriage() {
        if (!isFocused())
            return;

        if (editComponent.carriage.visible)
            renderer.renderQuad(
                renderData.carriageRenderObject,
                editComponent.carriage.absolutePosition
            );
    }

    // TODO: Update name to update text position and remove returning.
    // we have result in editComponent.absoluteTextPosition
    package vec2 getTextPosition() {
        auto textPosition = absolutePosition;

        if (textAlign == Align.left) {
            textPosition.x += renderData.textLeftMargin + editComponent.scrollDelta;
        }
        else if (textAlign == Align.right) {
            textPosition.x -= renderData.textRightMargin - editComponent.scrollDelta;
        }

        editComponent.absoulteTextPosition = textPosition;
        return textPosition;
    }

    protected override void onCreate() {
        super.onCreate();

        editComponent.carriage.bind(&editComponent);
        editComponent.renderData.onCreate(renderFactory, manager.theme, style);
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

    override void onMouseDown(in MouseDownEvent event) {
        if (autoSelectOnFocus)
            return;

        if (isEnter)
            editComponent.onMouseDown(event);
    }

    override void onMouseMove(in MouseMoveEvent event) {
        if (isEnter)
            editComponent.onMouseMove(event);
    }

    override void onDblClick(in DblClickEvent event) {
        if (isEnter)
            editComponent.onDblClick(event);
    }

private:
    EditComponent editComponent;
    NumberInputTypeComponent numberInputTypeComponent;

    @property RenderData renderData() { return editComponent.renderData; }
}
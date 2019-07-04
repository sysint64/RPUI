module rpui.widgets.text_input.widget;

import rpui.cursor;
import rpui.events;
import rpui.widget_events;
import rpui.input;
import rpui.math;
import rpui.primitives;
import rpui.widget;
import rpui.platform;
import rpui.widgets.text_input.renderer;
import rpui.widgets.text_input.edit_component;
import rpui.widgets.text_input.number_input_type_component;

class TextInput : Widget {
    enum InputType { text, integer, number }

    @field Align textAlign = Align.left;
    @field bool autoSelectOnFocus = false;
    @field float maxValue = float.max;
    @field float minValue = float.min_normal;
    @field float numberStep = 1f;

    private InputType inputType_ = InputType.text;

    @field
    @property InputType inputType() { return inputType_; }
    @property void inputType(in InputType val) {
        inputType_ = val;

        if (val == InputType.integer || val == InputType.number) {
            focusOnMousUp = true;
            autoSelectOnFocus = true;
        } else {
            focusOnMousUp = false;
        }
    }

    @field
    @property utf32string text() { return editComponent.text; }

    @property void text(in utf32string value) {
        editComponent.text = value;
    }

    @property utf32string selectedText() {
        return editComponent.text[editComponent.selectRegion.start .. editComponent.selectRegion.end];
    }

    package struct Measure {
        float textWidth = 0;
        float lineHeight = 0;
        float textTopMargin;
        float textLeftMargin;
        float textRightMargin;
        float carriageBoundary;
        vec2 textRelativePosition = vec2(0);
        float arrowsAreaWidth = 0;
    }

    package Measure measure;
    package EditComponent editComponent;
    package NumberInputTypeComponent numberInputTypeComponent;

    this(in string style = "TextInput") {
        super(style);
        this.drawChildren = false;
        this.renderer = new TextInputRenderer();
        this.drawChildren = false;

        size = vec2(50, 21);
    }

    override void onProgress(in ProgressEvent event) {
        editComponent.carriage.onProgress(event);
        updateCarriagePostion();
        updateScroll();

        if (isNumberMode()) {
        //     updateArrowAbsolutePositions();
            numberInputTypeComponent.updateArrowStates();
        }

        locator.updateAbsolutePosition();
        locator.updateLocationAlign();
        locator.updateVerticalLocationAlign();
        locator.updateRegionAlign();

        renderer.onProgress(event);
    }

    override void onCreate() {
        super.onCreate();

        loadMeasure();
        editComponent.carriage.attach(&editComponent);
        numberInputTypeComponent.attach(this);

        if (isNumberMode()) {
            textAlign = Align.center;
        }

        events.subscribe!CopyCommand(&onCopy);
        events.subscribe!CutCommand(&onCut);
        events.subscribe!PasteCommand(&onPaste);
        events.subscribe!UnselectCommand(&onUnselect);
        events.subscribe!SelectAllCommand(&onSelectAll);
    }

    private void onCopy(in CopyCommand command) {
        if (!isFocused) {
            return;
        }

        platformSetClipboardTextUtf32(selectedText);
        editComponent.unselect();
    }

    private void onCut(in CutCommand command) {
        if (!isFocused) {
            return;
        }

        if (selectedText.length == 0)
            return;

        platformSetClipboardTextUtf32(selectedText);
        editComponent.removeSelectedRegion();
        events.notify(ChangeEvent());
    }

    private void onPaste(in PasteCommand command) {
        if (!isFocused) {
            return;
        }

        const text = platformGetClipboardTextUtf32();

        if (editComponent.enterText(text))
            events.notify(ChangeEvent());
    }

    private void onUnselect(in UnselectCommand command) {
        if (!isFocused) {
            return;
        }

        editComponent.unselect();
    }

    private void onSelectAll(in SelectAllCommand command) {
        if (!isFocused) {
            return;
        }

        editComponent.selectAll();
    }

    private void loadMeasure() {
        with (view.theme.tree) {
            measure.textLeftMargin = data.getNumber(style ~ ".textLeftMargin.0");
            measure.textRightMargin = data.getNumber(style ~ ".textRightMargin.0");
            measure.textTopMargin = data.getNumber(style ~ ".textTopMargin.0");
            measure.carriageBoundary = data.getNumber(style ~ ".carriageBoundary.0");
            measure.arrowsAreaWidth = data.getNumber(style ~ ".arrowsAreaWidth.0");
        }
    }

    override void updateSize() {
        super.updateSize();
        updateCarriagePostion();

        if (isNumberMode()) {
            // updateArrowAbsolutePositions();
            numberInputTypeComponent.updateArrowStates();
        }
    }

    override void onBlur(in BlurEvent event) {
        editComponent.reset();
        editComponent.onBlur();
    }

    override void onFocus(in FocusEvent event) {
        editComponent.onFocus();

        if (autoSelectOnFocus && !isFocused)
            editComponent.selectAll();
    }

    package bool isNumberMode() {
        return inputType == InputType.integer || inputType == InputType.number;
    }

    package void pushScissor() {
        Rect scissor;
        scissor.point = vec2(
            absolutePosition.x + measure.textLeftMargin,
            absolutePosition.y
        );
        scissor.size = vec2(
            size.x - measure.textLeftMargin - measure.textRightMargin,
            size.y
        );

        view.pushScissor(scissor);
    }

    /// Change system cursor when mouse entering to arrows.
    override void onCursor() {
        if (isFocused && (isEnter || isClick)) {
            view.cursor = CursorIcon.iBeam;
        }

        if (numberInputTypeComponent.leftArrow.isEnter) {
            view.cursor = CursorIcon.normal;
        }
        else if (numberInputTypeComponent.rightArrow.isEnter) {
            view.cursor = CursorIcon.normal;
        }
    }

    private void updateScroll() {
        if (textAlign == Align.center) {
            editComponent.scrollDelta = 0;
            return;
        }

        const rightBorder = absolutePosition.x + size.x - measure.textRightMargin;
        const leftBorder = absolutePosition.x + measure.textLeftMargin;
        const padding = measure.textRightMargin + measure.textLeftMargin;
        const regionOffset = editComponent.getTextRegionSize(0, editComponent.carriage.pos);
        const textSize = cast(float) measure.textWidth;
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

// Events ------------------------------------------------------------------------------------------

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
        if (isEnter) {
            editComponent.onMouseDown(event);
        }

        if (isNumberMode())
            numberInputTypeComponent.onMouseDown(event);
    }

    override void onMouseUp(in MouseUpEvent event) {
        if (isNumberMode())
            numberInputTypeComponent.onMouseUp(event);
    }

    override void onMouseMove(in MouseMoveEvent event) {
        if (isEnter)
            editComponent.onMouseMove(event);

        if (isNumberMode())
            numberInputTypeComponent.onMouseMove(event);
    }

    override void onDblClick(in DblClickEvent event) {
        if (isEnter)
            editComponent.onDblClick(event);
    }

    override void onTripleClick(in TripleClickEvent event) {
        if (isEnter)
            editComponent.onTripleClick(event);
    }
}

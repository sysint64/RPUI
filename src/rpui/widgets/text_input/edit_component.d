module rpui.widgets.text_input.edit_component;

import std.algorithm.comparison;
import std.algorithm.searching;
import std.string;
import std.math;
import std.conv;

import rpui.input;
import rpui.primitives;
import rpui.math;
import rpui.widgets.text_input;
import rpui.widgets.text_input.select_component;
import rpui.widgets.text_input.carriage;
import rpui.widgets.text_input.transforms_system;
import rpui.events;
import rpui.theme;

struct EditComponent {
    const commonSplitChars = " ,.;:?'!|/\\~*+-=(){}<>[]#%&^@$№`\""d;
    const japanesePunctuation = "\u3000｛｝（）［］【】、，…‥。〽「」『』〝〟〜：！？"d;
    const splitChars = commonSplitChars ~ japanesePunctuation;

    utf32string text;
    Carriage carriage;
    float scrollDelta = 0.0f;
    vec2 absoulteTextPosition;

    SelectRegion selectRegion;
    TextInput textInput;
    TextInputTransformsSystem transformsSystem;
    private utf32string lastText;

    void attach(TextInput textInput, TextInputTransformsSystem transformsSystem) {
        this.textInput = textInput;
        this.transformsSystem = transformsSystem;
    }

    void reset() {
        selectRegion.stopSelection();
        carriage.reset();
    }

    void onKeyPressed(in KeyPressedEvent event) {
        carriage.timer = 0;
        carriage.visible = true;

        if (isKeyPressed(KeyCode.Shift) && !selectRegion.startedSelection)
            selectRegion.startSelection(carriage.pos);

        switch (event.key) {
            case KeyCode.Left:
                if (isKeyPressed(KeyCode.Ctrl)) {
                    carriage.setCarriagePos(carriage.navigateCarriage(-1));
                } else {
                    carriage.moveCarriage(-1);
                }

                break;

            case KeyCode.Right:
                if (isKeyPressed(KeyCode.Ctrl)) {
                    carriage.setCarriagePos(carriage.navigateCarriage(1));
                } else {
                    carriage.moveCarriage(1);
                }

                break;

            case KeyCode.Home:
                carriage.setCarriagePos(0);
                break;

            case KeyCode.End:
                carriage.setCarriagePos(cast(int) text.length);
                break;

            case KeyCode.Delete:
                if (selectRegion.textIsSelected()) {
                    removeSelectedRegion();
                } else {
                    if (isKeyPressed(KeyCode.Ctrl)) {
                        const end = carriage.navigateCarriage(1);
                        removeRegion(carriage.pos, end);
                    } else {
                        removeRegion(carriage.pos, carriage.pos+1);
                    }
                }
                break;

            case KeyCode.BackSpace:
                if (selectRegion.textIsSelected()) {
                    removeSelectedRegion();
                } else {
                    if (isKeyPressed(KeyCode.Ctrl)) {
                        const start = carriage.navigateCarriage(-1);
                        removeRegion(start, carriage.pos);
                    } else {
                        removeRegion(carriage.pos-1, carriage.pos);
                    }
                }
                break;

            default:
                // Nothing
        }
    }

    void removeSelectedRegion() {
        removeRegion(
            selectRegion.start,
            selectRegion.end
        );
    }

    void removeRegion(in int start, in int end) {
        if (start < 0 || end > text.length)
            return;

        const leftPart = text[0 .. start];
        const rightPart = text[end .. text.length];

        text = leftPart ~ rightPart;
        carriage.setCarriagePos(start);
    }

    private bool isISOControlCharacter(in utf32char ch) {
        // Control characters
        // https://www.utf8-chartable.de/unicode-utf8-table.pl?utf8=0x
        return (ch >= 0x00 && ch <= 0x1F) || (ch >= 0x7F && ch <= 0x9F);
    }

    bool onTextEntered(in TextEnteredEvent event) {
        carriage.timer = 0;
        carriage.visible = true;

        const charToPut = event.key;

        if (isISOControlCharacter(charToPut))
            return false;

        // Splitting text to two parts by carriage position

        utf32string leftPart;
        utf32string rightPart;
        auto newCarriagePos = carriage.pos;

        if (!selectRegion.textIsSelected()) {
            leftPart = text[0 .. carriage.pos];
            rightPart = text[carriage.pos .. $];
            newCarriagePos++;
        }
        else {
            leftPart = text[0 .. selectRegion.start];
            rightPart = text[selectRegion.end .. $];
            newCarriagePos = selectRegion.start + 1;
        }

        const newText = leftPart ~ charToPut ~ rightPart;

        text = newText;
        carriage.pos = newCarriagePos;

        selectRegion.stopSelection();
        return true;
    }

    void onMouseDown(in MouseDownEvent event) {
        if (textInput.autoSelectOnFocus)
            return;

        carriage.setCarriagePosFromMousePos(event.x, event.y);

        if (!isKeyPressed(KeyCode.Shift))
            selectRegion.startSelection(carriage.pos);
    }

    void onMouseMove(in MouseMoveEvent event) {
        if (event.button != MouseButton.mouseLeft)
            return;

        // if (!textInput.isNumberMode())
        if (textInput.isFocused)
            carriage.setCarriagePosFromMousePos(event.x, event.y);
    }

    void onDblClick(in DblClickEvent event) {
        const left = carriage.navigateCarriage(-1);
        const right = carriage.navigateCarriage(1);

        selectRegion.start = left;
        selectRegion.end = right;
        carriage.pos = right;
    }

    float getTextWidth() {
        return textInput.measure.textWidth;
    }

    float getTextRegionSize(in int start, in int end)
        // in(start <= end)
    {
        if (start == end)
            return 0.0f;

        return transformsSystem.getRegionTextWidth(start, end);
    }

    vec2 getTextRegionOffset(in int charPos) {
        const regionSize = getTextRegionSize(0, charPos);
        const offset = vec2(
            regionSize + scrollDelta,
            textInput.measure.textTopMargin
        );

        float alignOffset = 0;

        if (textInput.textAlign == Align.left) {
            alignOffset = textInput.measure.textLeftMargin;
        }
        else if (textInput.textAlign == Align.right) {
            alignOffset = -textInput.measure.textRightMargin;
        }

        return vec2(alignOffset - textInput.measure.carriageBoundary, 0) +
            textInput.measure.textRelativePosition + offset;
    }

    void selectAll() {
        selectRegion.start = 0;
        selectRegion.end = cast(int) text.length;
        selectRegion.startedSelection = true;
        carriage.pos = selectRegion.end;
    }

    void onFocus() {
        lastText = textInput.text;
    }

    void onBlur() {
        switch (textInput.inputType) {
            case TextInput.InputType.integer:
                if (!isNumeric(textInput.text)) {
                    textInput.text = lastText;
                } else {
                    const value = textInput.text.to!float;
                    textInput.text = round(value).to!utf32string;
                }

                break;

            case TextInput.InputType.number:
                if (!isNumeric(textInput.text))
                    textInput.text = lastText;

                break;

            case TextInput.InputType.text:
                return;

            default:
                return;
        }
    }
}

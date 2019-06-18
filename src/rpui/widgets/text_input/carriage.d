module rpui.widgets.text_input.carriage;

import rpui.input;
import rpui.events;
import rpui.math;
import rpui.widgets.text_input.edit_component;
import std.algorithm.comparison;
import std.algorithm.searching;
import rpui.theme;

struct Carriage {
    const commonSplitChars = " ,.;:?'!|/\\~*+-=(){}<>[]#%&^@$№`\""d;
    const japanesePunctuation = "\u3000｛｝（）［］【】、，…‥。〽「」『』〝〟〜：！？"d;
    const splitChars = commonSplitChars ~ japanesePunctuation;

    float timer = 0;
    int pos = 0;
    bool visible = true;
    const blinkThreshold = 2f;
    vec2 absolutePosition;
    float scrollDelta = 0.0f;

    EditComponent *editComponent;

    void attach(EditComponent *editComponent) {
        this.editComponent = editComponent;
    }

    void reset() {
        pos = 0;
        visible = true;
        timer = 0;
        scrollDelta = 0;
    }

    void onProgress(in ProgressEvent event) {
        if (!editComponent.textInput.isFocused) {
            timer = 0;
            return;
        }

        timer += event.deltaTime;

        if (timer >= blinkThreshold) {
            visible = !visible;
            timer = 0;
        }
    }

    void moveCarriage(in int delta) {
        setCarriagePos(pos + delta);
    }

    int navigateCarriage(in int direction)
        // in(direction == -1 || direction == 1)
    {
        int i = pos + direction;

        if (i <= 0 || i >= editComponent.text.length)
            return clamp(i, 0, editComponent.text.length);

        auto skipSplitChars = splitChars.canFind(editComponent.text[i]);

        while (true) {
            i += direction;

            if (i <= 0 || i >= editComponent.text.length)
                return clamp(i, 0, editComponent.text.length);

            if (splitChars.canFind(editComponent.text[i])) {
                if (!skipSplitChars)
                    return direction == -1 ? i + 1 : i;
            } else {
                skipSplitChars = false;
            }
        }
    }

    void setCarriagePos(in int newPos) {
        timer = 0;
        visible = true;

        pos = clamp(newPos, 0, editComponent.text.length);
        editComponent.selectRegion.updateSelect(pos);

        if (!isKeyPressed(KeyCode.Shift))
            editComponent.selectRegion.stopSelection();
    }

    void setCarriagePosWithoutCheckSelection(in int newPos) {
        timer = 0;
        visible = true;

        pos = clamp(newPos, 0, editComponent.text.length);
        editComponent.selectRegion.updateSelect(pos);
    }

    void setCarriagePosFromMousePos(in int x, in int y) {
        const relativeCursorPos = x - editComponent.absoulteTextPosition.x;

        if (x > editComponent.absoulteTextPosition.x + editComponent.getTextWidth()) {
            setCarriagePosWithoutCheckSelection(cast(int) editComponent.text.length);
            return;
        }

        /**
         * Find optimal position
         * Traverse all sizes of slice of text from [0..1, 0..2, ... , 0..text.size()-1]
         * And get max size with condition: size <= bmax
         */
        for (int i = 0; i < editComponent.text.length; ++i) {
            const sliceWidth = editComponent.getTextRegionSize(0, i);

            if (sliceWidth + 6 > relativeCursorPos) {
                setCarriagePosWithoutCheckSelection(i);
                break;
            }
        }
    }
}

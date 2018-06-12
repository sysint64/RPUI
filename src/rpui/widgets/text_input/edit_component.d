module rpui.widgets.text_input.edit_component;

import input;
import basic_types;
import math.linalg;
import std.algorithm.comparison;
import std.algorithm.searching;

import rpui.widgets.text_input;
import rpui.render_objects;
import rpui.events;

struct EditComponent {
    const commonSplitChars = " ,.;:?'!|/\\~*+-=(){}<>[]#%&^@$№`\""d;
    const japanesePunctuation = "\u3000｛｝（）［］【】、，…‥。〽「」『』〝〟〜：！？"d;
    const splitChars = commonSplitChars ~ japanesePunctuation;

    utfstring text;

    struct Carriage {
        float timer = 0;
        int lastPos = 0;
        int pos = 0;
        bool visible = true;
        BaseRenderObject renderObject;
        const blinkThreshold = 500f;
        vec2 absolutePosition;
    }

    struct SelectRegion {
        int start;
        int end;
    }

    TextInput textInput;
    Carriage carriage;
    SelectRegion selectRegion;
    float scrollDelta = 0.0f;

    void updateSelect() {
    }

    void onKeyPressed(in KeyPressedEvent event) {
        switch (event.key) {
            case KeyCode.Left:
                if (isKeyPressed(KeyCode.Ctrl)) {
                    setCarriagePos(navigateCarriage(-1));
                } else {
                    moveCarriage(-1);
                }

                break;

            case KeyCode.Right:
                if (isKeyPressed(KeyCode.Ctrl)) {
                    setCarriagePos(navigateCarriage(1));
                } else {
                    moveCarriage(1);
                }

                break;

            case KeyCode.Home:
                setCarriagePos(0);
                break;

            case KeyCode.End:
                setCarriagePos(cast(int) text.length);
                break;

            case KeyCode.Delete:
                removeRegion(carriage.pos, carriage.pos+1);
                break;

            case KeyCode.Back:
                removeRegion(carriage.pos-1, carriage.pos);
                break;

            default:
                // Nothing
        }
    }

    void moveCarriage(in int delta) {
        setCarriagePos(carriage.pos + delta);
    }

    // TODO: dmd PR #8155
    int navigateCarriage(in int direction)
    in {
        assert(direction == -1 || direction == 1);
    }
    do {
        int i = carriage.pos + direction;

        if (i <= 0 || i >= text.length)
            return clamp(i, 0, text.length);

        auto skipSplitChars = splitChars.canFind(text[i]);

        while (true) {
            i += direction;

            if (i <= 0 || i >= text.length)
                return clamp(i, 0, text.length);

            if (splitChars.canFind(text[i])) {
                if (!skipSplitChars)
                    return direction == -1 ? i + 1 : i;
            } else {
                skipSplitChars = false;
            }
        }
    }

    // TODO: dmd PR #8155
    int findPosUntilSeparator(in int direction)
    in {
        assert(direction == -1 || direction == 1);
    }
    do {
        int i = carriage.pos;

        if (i + direction <= 0 || i + direction >= text.length)
            return i;

        while (true) {
            i += direction;

            if (i <= 0)
                return i;

            if (i >= text.length)
                return i;

            if (splitChars.canFind(text[i]))
                return i;
        }
    }

    void setCarriagePos(in int newPos) {
        carriage.pos = clamp(newPos, 0, text.length);
        updateSelect();
    }

    void removeRegion(in int start, in int end) {
        if (start < 0 || end > text.length)
            return;

        const leftPart = text[0 .. start];
        const rightPart = text[end .. text.length];

        text = leftPart ~ rightPart;
        setCarriagePos(start);
    }
}

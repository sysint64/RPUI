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
        int pos = 0;
        bool visible = true;
        BaseRenderObject renderObject;
        const blinkThreshold = 500f;
        vec2 absolutePosition;
    }

    struct SelectRegion {
        int start = 0;
        int end = 0;
        vec2 size;
        vec2 absolutePosition;
    }

    TextInput textInput;
    Carriage carriage;
    SelectRegion selectRegion;
    float scrollDelta = 0.0f;
    bool startedSelection = false;
    int startSelectionPos = 0;

    void updateSelect() {
        if (!startedSelection)
            return;

        selectRegion.start = startSelectionPos;
        selectRegion.end = carriage.pos;

        clampSelectRegion();
    }

    void clampSelectRegion() {
        const regionMin = min(selectRegion.start, selectRegion.end);
        const regionMax = max(selectRegion.start, selectRegion.end);

        selectRegion.start = regionMin;
        selectRegion.end = regionMax;
    }

    void startSelection() {
        startedSelection = true;
        startSelectionPos = carriage.pos;
        selectRegion.start = startSelectionPos;
        selectRegion.end = startSelectionPos;
    }

    void stopSelection() {
        startedSelection = false;
        selectRegion.start = 0;
        selectRegion.end = 0;
        startSelectionPos = 0;
    }

    void reset() {
        stopSelection();
        carriage.pos = 0;
        carriage.visible = true;
        carriage.timer = 0;
        scrollDelta = 0;
    }

    void onKeyPressed(in KeyPressedEvent event) {
        if (isKeyPressed(KeyCode.Shift) && !startedSelection)
            startSelection();

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
                if (textIsSelected()) {
                    removeSelectedRegion();
                } else {
                    if (isKeyPressed(KeyCode.Ctrl)) {
                        const end = navigateCarriage(1);
                        removeRegion(carriage.pos, end);
                    } else {
                        removeRegion(carriage.pos, carriage.pos+1);
                    }
                }
                break;

            case KeyCode.Back:
                if (textIsSelected()) {
                    removeSelectedRegion();
                } else {
                    if (isKeyPressed(KeyCode.Ctrl)) {
                        const start = navigateCarriage(-1);
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

    bool textIsSelected() {
        return selectRegion.start != selectRegion.end;
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
        const oldPos = carriage.pos;
        carriage.pos = clamp(newPos, 0, text.length);
        updateSelect();

        if (!isKeyPressed(KeyCode.Shift))
            stopSelection();
    }

    void removeSelectedRegion() {
        removeRegion(selectRegion.start, selectRegion.end);
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

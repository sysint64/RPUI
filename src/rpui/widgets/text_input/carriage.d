module rpui.widgets.text_input.carriage;

import input;
import rpui.renderer;
import rpui.render_objects;
import rpui.events;
import rpui.renderer;
import rpui.render_factory;
import math.linalg;
import rpui.widgets.text_input.edit_component;
import std.algorithm.comparison;
import std.algorithm.searching;
import rpui.theme;

struct Carriage {
    const commonSplitChars = " ,.;:?'!|/\\~*+-=(){}<>[]#%&^@$№`\""d;
    const japanesePunctuation = "\u3000｛｝（）［］【】、，…‥。〽「」『』〝〟〜：！？"d;
    const splitChars = commonSplitChars ~ japanesePunctuation;

    // EditSystem editSystem;
    float timer = 0;
    int pos = 0;
    bool visible = true;
    const blinkThreshold = 500f;
    vec2 absolutePosition;
    float scrollDelta = 0.0f;

    EditComponent *editComponent;

    void bind(EditComponent *editComponent) {
        this.editComponent = editComponent;
    }

    void reset() {
        pos = 0;
        visible = true;
        timer = 0;
        scrollDelta = 0;
    }

    void onProgress(in float deltaTime) {
        timer += deltaTime;

        if (timer >= blinkThreshold) {
            visible = !visible;
            timer = 0;
        }
    }

    void moveCarriage(in int delta) {
        setCarriagePos(pos + delta);
    }

    // TODO: dmd PR #8155
    int navigateCarriage(in int direction)
    in {
        assert(direction == -1 || direction == 1);
    }
    do {
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

    // TODO: dmd PR #8155
    int findPosUntilSeparator(in int direction)
    in {
        assert(direction == -1 || direction == 1);
    }
    do {
        int i = pos;

        if (i + direction <= 0 || i + direction >= editComponent.text.length)
            return i;

        while (true) {
            i += direction;

            if (i <= 0)
                return i;

            if (i >= editComponent.text.length)
                return i;

            if (splitChars.canFind(editComponent.text[i]))
                return i;
        }
    }

    void setCarriagePos(in int newPos) {
        const oldPos = pos;
        pos = clamp(newPos, 0, editComponent.text.length);
        editComponent.selectRegion.updateSelect(pos);

        if (!isKeyPressed(KeyCode.Shift))
            editComponent.selectRegion.stopSelection();
    }
}

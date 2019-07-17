module rpui.widgets.text_input.select_component;

import std.algorithm.comparison;
import rpui.math;
import rpui.theme;
import rpui.widgets.text_input.widget;
import rpui.widgets.text_input.edit_component;
import rpui.primitives;

struct SelectRegion {
    int start = 0;
    int end = 0;
    vec2 size;
    vec2 absolutePosition;

    bool startedSelection = false;
    int startSelectionPos = 0;
    EditComponent* editComponent;

    void attach(EditComponent* editComponent) {
        this.editComponent = editComponent;
    }

    void updateSelect(in int pos) {
        if (!startedSelection)
            return;

        start = startSelectionPos;
        end = pos;

        clampSelectRegion();
    }

    void clampSelectRegion() {
        const regionMin = min(start, end);
        const regionMax = max(start, end);

        start = regionMin;
        end = regionMax;

        start = max(0, start);
        end = min(end, cast(int) editComponent.text.length);
    }

    void startSelection(in int pos) {
        startedSelection = true;
        startSelectionPos = pos;
        start = startSelectionPos;
        end = startSelectionPos;
    }

    void stopSelection() {
        startedSelection = false;
        start = 0;
        end = 0;
        startSelectionPos = 0;
    }

    bool textIsSelected() {
        return start != end;
    }
}

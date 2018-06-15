module rpui.widgets.text_input.select_component;

import std.algorithm.comparison;
import math.linalg;
import gapi;
import rpui.render_objects;
import rpui.renderer;
import rpui.render_factory;
import rpui.theme;
import rpui.widgets.text_input;
import rpui.widgets.text_input.edit_component;
import basic_types;

struct SelectRegion {
    int start = 0;
    int end = 0;
    vec2 size;
    vec2 absolutePosition;

    bool startedSelection = false;
    int startSelectionPos = 0;

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

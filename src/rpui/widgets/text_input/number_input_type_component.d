module rpui.widgets.text_input.number_input_type_component;

import std.conv;
import std.math;
import std.stdio;

import math.linalg;
import basic_types;
import rpui.events;
import rpui.widgets.text_input;

struct NumberInputTypeComponent {
    struct Arrow {
        vec2 absolutePosition;
        Rect area;
        bool isEnter = false;

        @property string state() {
            return isEnter ? "Enter" : "Leave";
        }
    }

    Arrow leftArrow;
    Arrow rightArrow;

    TextInput textInput;
    float delta = 0;
    bool isClick = false;
    int startX = 0;
    int startY = 0;
    int value = 0;
    int initialValue = 0;
    float step = 5.0f;
    bool shouldBlur = false;

    void bind(TextInput textInput) {
        this.textInput = textInput;
    }

    void onMouseDown(in MouseDownEvent event) {
        if (leftArrow.isEnter) {
            shouldBlur = true;
            addValue(-1);
            return;
        }

        if (rightArrow.isEnter) {
            shouldBlur = true;
            addValue(1);
            return;
        }

        if (!textInput.isEnter || textInput.isFocused)
            return;

        isClick = true;
        delta = 0;
        startX = event.x;
        startY = event.y;
        initialValue = value;
        shouldBlur = false;
        textInput.app.hideCursor();
        textInput.freezeUI();
    }

    void onMouseMove(in MouseMoveEvent event) {
        if (!isClick)
            return;

        delta = (event.x - startX) / step;
        writeln(delta);

        if (delta > 0) {
            addValue(floor(delta).to!(int));
        } else {
            addValue(ceil(delta).to!(int));
        }

        if (abs(delta) >= 1) {
            textInput.app.setMousePositon(startX, startY);
            shouldBlur = true;
        }
    }

    void onMouseUp(in MouseUpEvent event) {
        textInput.unfreezeUI();

        if (shouldBlur) {
            shouldBlur = false;
            textInput.blur();
            // TODO: notify on change event
        }

        delta = 0;
        startX = 0;
        isClick = false;
        textInput.app.showCursor();
    }

    void onBlur() {
    }

    void addValue(in int delta) {
        value = textInput.text.to!(int) + delta;
        textInput.text = value.to!(dstring);
    }
}

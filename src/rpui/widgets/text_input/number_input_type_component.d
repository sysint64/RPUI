module rpui.widgets.text_input.number_input_type_component;

import std.conv;
import std.math;

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
    float value = 0;
    float initialValue = 0;
    float mouseSensetive = 20.0f;
    bool avoidFocusing = false;

    void bind(TextInput textInput) {
        this.textInput = textInput;
    }

    void onMouseDown(in MouseDownEvent event) {
        if (leftArrow.isEnter) {
            textInput.blur();
            avoidFocusing = true;
            addValue(-1);
            return;
        }

        if (rightArrow.isEnter) {
            textInput.blur();
            avoidFocusing = true;
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
        avoidFocusing = false;
        textInput.app.hideCursor();
        textInput.freezeUI();
    }

    void onMouseMove(in MouseMoveEvent event) {
        if (!isClick)
            return;

        delta = (event.x - startX) / mouseSensetive;

        if (delta > 0) {
            addValue(floor(delta).to!int);
        } else {
            addValue(ceil(delta).to!int);
        }

        if (abs(delta) >= 1) {
            textInput.app.setMousePositon(startX, startY);
            avoidFocusing = true;
            delta = 0;
        }
    }

    void onMouseUp(in MouseUpEvent event) {
        textInput.unfreezeUI();

        if (avoidFocusing) {
            avoidFocusing = false;
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

    void addValue(in float sign) {
        if (sign == 0)
            return;

        value = textInput.text.to!(float) + sign * textInput.numberStep;
        textInput.text = value.to!(dstring);
    }
}

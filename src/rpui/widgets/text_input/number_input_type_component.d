module rpui.widgets.text_input.number_input_type_component;

import math.linalg;
import basic_types;

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
}

module rpui.widgets.panel.header;

import rpui.widgets.panel;
import rpui.math;
import rpui.basic_types;
import rpui.render_objects;

struct Header {
    float height = 0;
    bool isEnter = false;
    Panel panel;

    void attach(Panel panel) {
        this.panel = panel;
    }

    void onProgress() {
        assert(panel !is null);

        if (!panel.userCanHide)
            return;

        const vec2 size = vec2(panel.size.x, height);
        Rect rect = Rect(panel.absolutePosition, size);
        isEnter = pointInRect(panel.view.mousePos, rect);
    }

    @property inout(State) state() inout {
        if (isEnter) {
            return State.enter;
        } else {
            return State.leave;
        }
    }
}

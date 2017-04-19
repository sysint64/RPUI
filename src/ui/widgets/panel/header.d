module ui.widgets.panel.header;

import gapi;
import e2ml;
import math.linalg;
import basic_types;
import application;

import ui.theme;
import ui.render_objects;
import ui.render_factory;
import ui.renderer;

import ui.widgets.panel.widget;


package struct Header {
    Application app;

    BaseRenderObject backgroundRenderObject;
    BaseRenderObject arrowRenderObject;

    float height = 0;
    bool isEnter = false;
    Panel panel;
    Renderer renderer;
    vec2 arrowSize;
    vec2 arrowPosition;

    void onCreate(Panel panel, Theme theme, Renderer renderer) {
        app = Application.getInstance();

        this.panel = panel;
        this.renderer = renderer;
        const string style = panel.style;
        Data styleData = theme.data;

        height = styleData.getNumber(style ~ ".Header.height.0");
        panel.renderFactory.createQuad(backgroundRenderObject);

        const Texture.Coord leaveTexCoord = styleData.getTexCoord(style ~ ".Header.leave");
        const Texture.Coord enterTexCoord = styleData.getTexCoord(style ~ ".Header.enter");

        backgroundRenderObject.addTexCoord("Leave", leaveTexCoord, theme.skin);
        backgroundRenderObject.addTexCoord("Enter", enterTexCoord, theme.skin);

        // Header arrow (open/close)
        panel.renderFactory.createQuad(arrowRenderObject);

        const Texture.Coord arrowOpenTexCoord  = styleData.getTexCoord(style ~ ".Header.Arrow.open");
        const Texture.Coord arrpwCloseTexCoord = styleData.getTexCoord(style ~ ".Header.Arrow.close");

        arrowSize = styleData.getVec2f(style ~ ".Header.Arrow.size");
        arrowPosition = styleData.getVec2f(style ~ ".Header.Arrow.position");

        arrowRenderObject.addTexCoord("Open", arrowOpenTexCoord, theme.skin);
        arrowRenderObject.addTexCoord("Close", arrpwCloseTexCoord, theme.skin);
    }

    @property string state() {
        return isEnter ? "Enter" : "Leave";
    }

    @property string arrowState() {
        return panel.isOpen ? "Open" : "Close";
    }

    void onProgress() {
        if (!panel.allowHide)
            return;

        const vec2 size = vec2(panel.size.x, height);
        Rect rect = Rect(panel.absolutePosition, size);
        isEnter = pointInRect(app.mousePos, rect);
    }

    void render() {
        if (!panel.allowHide)
            return;

        renderer.renderQuad(backgroundRenderObject, state,
                            panel.absolutePosition, vec2(panel.size.x, height));
        renderer.renderQuad(arrowRenderObject, arrowState,
                            panel.absolutePosition + arrowPosition, arrowSize);
    }
}

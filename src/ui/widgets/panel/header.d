module ui.widgets.panel.header;

import gapi;
import e2ml;
import math.linalg;
import basic_types;

import ui.theme;
import ui.render_objects;
import ui.render_factory;
import ui.renderer;

import ui.widgets.panel.widget;


package struct Header {
    BaseRenderObject backgroundRenderObject;
    BaseRenderObject arrowRenderObject;

    float height = 0;
    bool isEnter = false;
    Panel panel;
    Renderer renderer;

    void onCreate(Panel panel, Theme theme, Renderer renderer) {
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

        const Texture.Coord arrowOpen  = styleData.getTexCoord(style ~ ".Header.arrowOpen");
        const Texture.Coord arrpwClose = styleData.getTexCoord(style ~ ".Header.arrowClose");

        arrowRenderObject.addTexCoord("Open", leaveTexCoord, theme.skin);
        arrowRenderObject.addTexCoord("Close", enterTexCoord, theme.skin);
    }

    @property string state() {
        return isEnter ? "Enter" : "Leave";
    }

    void render() {
        renderer.renderQuad(arrowRenderObject, "Close", panel.absolutePosition, vec2(10, 10));
    }
}

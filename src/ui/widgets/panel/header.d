module ui.widgets.panel.header;

import gapi;
import rpdl;
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
    TextRenderObject textRenderObject;

    float height = 0;
    bool isEnter = false;
    Panel panel;
    Renderer renderer;
    vec2 arrowSize;
    vec2 arrowPosition;

    void onCreate(Panel panel, Theme theme, Renderer renderer) {
        app = Application.getInstance();
        RPDLTree styleData = theme.data;

        this.panel = panel;
        this.renderer = renderer;
        immutable string style = panel.style;
        immutable states = ["Leave", "Enter"];
        immutable headerStyle = style ~ ".Header";

        height = styleData.getNumber(headerStyle ~ ".height.0");
        panel.renderFactory.createQuad(backgroundRenderObject, headerStyle, states, "background");

        // Header arrow (open/close)
        panel.renderFactory.createQuad(arrowRenderObject);

        const Texture.Coord arrowOpenTexCoord  = styleData.getTexCoord(headerStyle ~ ".Arrow.open");
        const Texture.Coord arrpwCloseTexCoord = styleData.getTexCoord(headerStyle ~ ".Arrow.close");

        arrowSize = styleData.getVec2f(headerStyle ~ ".Arrow.size");
        arrowPosition = styleData.getVec2f(headerStyle ~ ".Arrow.position");

        arrowRenderObject.addTexCoord("Open", arrowOpenTexCoord, theme.skin);
        arrowRenderObject.addTexCoord("Close", arrpwCloseTexCoord, theme.skin);

        textRenderObject = panel.renderFactory.createText(headerStyle, states);
        textRenderObject.text = panel.caption;
        textRenderObject.textAlign = Align.left;
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

        immutable vec2 headerSize = vec2(panel.size.x, height);
        renderer.renderQuad(backgroundRenderObject, state,
                            panel.absolutePosition, headerSize);
        renderer.renderQuad(arrowRenderObject, arrowState,
                            panel.absolutePosition + arrowPosition, arrowSize);

        immutable vec2 textPosition = panel.absolutePosition +
            vec2(arrowPosition.x + arrowSize.x, 0);

        renderer.renderText(textRenderObject, state, textPosition, headerSize);
    }
}

module ui.render_factory;

import gapi;
import application;
import math.linalg;

import ui.manager;
import ui.render_objects;
import ui.theme;


class RenderFactory {
    this(Manager manager) {
        this.manager = manager;
        this.quadGeometry = gapi.GeometryFactory.createSprite();
        this.app = Application.getInstance();
    }

    void createQuad(ref BaseRenderObject[string] renderObjects, in string style,
                    in string[] states, in string part)
    {
        renderObjects[part] = createQuad(style, states, part);
    }

    void createQuad(ref BaseRenderObject[string] renderObjects, in string style,
                    in string state, in string part)
    {
        renderObjects[part] = createQuad(style, state, part);
    }

    BaseRenderObject createQuad(in string style, in string state, in string part) {
        return createQuad(style, [state], part);
    }

    BaseRenderObject createQuad(in string style, in string[] states, in string part) {
        BaseRenderObject object = new BaseRenderObject(quadGeometry);

        foreach (string state; states) {
            string path = style ~ "." ~ state ~ "." ~ part;

            gapi.Texture.Coord texCoord = manager.theme.data.getTexCoord(path);
            texCoord.normalize(manager.theme.skin);
            object.addTexCoord(state, texCoord);
        }

        return object;
    }

    TextRenderObject createText(in string style, in string[] states, in string part = "text") {
        ThemeFont font = manager.theme.regularFont;
        TextRenderObject text = new TextRenderObject.Builder(quadGeometry)
            .setTextSize(font.defaultFontSize)
            .setFont(font)
            .build();

        foreach (string state; states) {
            const string path = style ~ "." ~ state ~ "." ~ part;
            const string offsetPath = path ~ "Offset";
            const string colorPath = path ~ "Color";

            vec2i offset = manager.theme.data.getVec2i(offsetPath);
            vec4 color = manager.theme.data.getNormColor(colorPath);

            text.addOffset(state, offset);
            text.addColor(state, color);
        }

        return text;
    }

private:
    Application app;
    gapi.Geometry quadGeometry;
    Manager manager;
}

module ui.render_factory;

import gapi;
import application;

import ui.manager;
import ui.render_objects;


class RenderFactory {
    this(Manager manager) {
        this.manager = manager;
        this.quadGeometry = gapi.GeometryFactory.createSprite();
    }

    BaseRenderObject createQuad(in string style, in string[] states, in string part) {
        BaseRenderObject object = new BaseRenderObject(quadGeometry);

        foreach (string state; states) {
            string path = style ~ "." ~ state ~ "." ~ part;

            Application app = Application.getInstance();
            gapi.Texture.Coord texCoord = manager.theme.data.getTexCoord(path);
            texCoord.normalize(manager.theme.skin);
            object.addTexCoord(state, texCoord);
        }

        return object;
    }

    TextRenderObject createText() {
        return null;
    }

private:
    Geometry quadGeometry;
    Manager manager;
}

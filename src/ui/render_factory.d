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

    BaseRenderObject createQuad(string style, string[] elements, string part = "") {
        BaseRenderObject object = new BaseRenderObject(quadGeometry);

        foreach (string element; elements) {
            string path = style ~ "." ~ element;

            if (part != "")
                path ~= "." ~ part;

            Application app = Application.getInstance();
            gapi.Texture.Coord texCoord = manager.theme.data.getTexCoord(path);
            texCoord.normalize(manager.theme.skin);
            object.addTexCoord(texCoord);
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

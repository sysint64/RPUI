/**
 * Helper to creating rendering objects.
 *
 * Copyright: © 2017 RedGoosePaws
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 * Authors: Andrey Kabylin
 */

module rpui.render_factory;

import gapi;
import application;
import math.linalg;

import rpui.manager;
import rpui.render_objects;
import rpui.theme;

/// Factory of different renderable objects for render UI.
class RenderFactory {
    /// Create render factory for UI manager.
    this(Manager manager) {
        this.manager = manager;
        this.quadGeometry = gapi.GeometryFactory.createSprite();
        this.app = Application.getInstance();
    }

    /**
     * Create quad render object and extract texture coordinates from theme rpdl
     * data for all `states`.
     *
     * For each state rpdl accessor will build like this: $(I style.state.part)
     *
     * Params:
     *     style = root rpdl node, e.g. $(I Button)
     *     states = element states, e.g. $(I ["Leave", "Enter", "Click"])
     *     part = part to extract texture coordinate, e.g. $(I "left")
     *
     * Example:
     * ---
     * const states = ["Leave", "Enter", "Click"]
     *
     * // Accessor for left part and Leave state:
     * //     Button.Leave.left
     * auto leftQuad = createQuad("Button", states, "left");
     * auto centerQuad = createQuad("Button", states, "center");
     * auto rightQuad = createQuad("Button", states, "right");
     * ---
     */
    BaseRenderObject createQuad(in string style, in string[] states, in string part = "") {
        BaseRenderObject object = new BaseRenderObject(quadGeometry);

        foreach (string state; states) {
            string path = style ~ "." ~ state;

            if (part != "")
                path ~= "." ~ part;

            Texture.Coord texCoord = manager.theme.tree.data.getTexCoord(path);
            texCoord.normalize(manager.theme.skin);
            object.addTexCoord(state, texCoord);
        }

        return object;
    }

    /**
     * Create text render object and extract color and offset from theme rpdl data
     * for all `states`.
     *
     * For each state rpdl accessor will build like this:
     *     $(I `style`.`states`[i].`part` ~ "Offset"),
     *     $(I `style`.`states`[i].`part` ~ "Color")
     *
     * Params:
     *     style = root rpdl node, e.g. $(I Button)
     *     states = element states, e.g. $(I ["Leave", "Enter", "Click"])
     *     prefix = prefix of parameter name, e.g. if prefx = $(I "text")
     *              then parameters will be $(I textColor) and $(I textOffset)
     *
     * Example:
     * ---
     * const states = ["Leave", "Enter", "Click"]
     *
     * // Rpdl accessors for Leave state:
     * //     Button.Leave.textColor;
     * //     Button.Leave.textOffset
     * auto captionText = createText("Button", states);
     * ---
     */
    TextRenderObject createText(in string style, in string[] states, in string prefix = "text") {
        ThemeFont font = manager.theme.regularFont;
        TextRenderObject text = new TextRenderObject.Builder(quadGeometry)
            .setTextSize(font.defaultFontSize)
            .setFont(font)
            .build();

        foreach (string state; states) {
            const string path = style ~ "." ~ state ~ "." ~ prefix;
            const string offsetPath = path ~ "Offset";
            const string colorPath = path ~ "Color";

            const vec2 offset = manager.theme.tree.data.getVec2f(offsetPath);
            const vec4 color = manager.theme.tree.data.getNormColor(colorPath);

            text.addOffset(state, offset);
            text.addColor(state, color);
        }

        return text;
    }

    /**
     * Create quad render object for particular `state` and extract texture coordinates from theme rpdl.
     * result will be stored to `renderObjects`[`part`].
     */
    void createQuad(ref BaseRenderObject[string] renderObjects, in string style,
                    in string[] states, in string part)
    {
        renderObjects[part] = createQuad(style, states, part);
    }

    /**
     * Create quad render object and extract texture coordinates from theme rpdl
     * data for all `states`. Result will be stored to `renderObject`.
     */
    void createQuad(ref BaseRenderObject renderObject, in string style,
                    in string[] states, in string part = "")
    {
        renderObject = createQuad(style, states, part);
    }

    /**
     * Create quad render object for particular `state` and extract texture coordinates from theme rpdl.
     * result will be stored to `renderObjects`[`part`].
     */
    void createQuad(ref BaseRenderObject[string] renderObjects, in string style,
                    in string state, in string part)
    {
        renderObjects[part] = createQuad(style, state, part);
    }

    /// Create quad render object.
    BaseRenderObject createQuad() {
        return new BaseRenderObject(quadGeometry);
    }

    /// Create quad render object. Result will be stored to `renderObject`.
    void createQuad(ref BaseRenderObject renderObject) {
        renderObject = new BaseRenderObject(quadGeometry);
    }

    /**
     * Create quad render object and extract texture coordinates from theme rpdl
     * data for particular `state`.
     */
    BaseRenderObject createQuad(in string style, in string state, in string part) {
        return createQuad(style, [state], part);
    }

private:
    Application app;
    gapi.Geometry quadGeometry;
    Manager manager;
}

/**
 * Rendering helper.
 *
 * Copyright: © 2017 Andrey Kabylin
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 */

module rpui.renderer;

import std.conv;
import std.math;
import gapi;
import math.linalg;
import accessors;
import basic_types;

import application;
import rpui.render_objects;
import rpui.manager;
import resources.icons;

/// Renderer is responsible for render different objects such as quads, texts, chains etc.
final class Renderer {
    /// Create renderer for UI manager.
    this(Manager manager) {
        this.manager = manager;
        app = Application.getInstance();
        initShaders();
    }

    /**
     * Converts world position to screen position.
     *
     * Params:
     *     position = world position.
     *     size = size of element to be rendered.
     */
    vec2 toScreenPosition(in vec2 position, in vec2 size) {
        return vec2(floor(position.x), floor(app.windowHeight - size.y - position.y));
    }

    /**
     * Renders `renderObject` for particular `state` and update `position` and `size`
     * for `renderObject`.
     *
     * Params:
     *     renderObject = object to be rendered.
     *     state = uses texture coordinates for state.
     *     position = new position for `renderObject`.
     *     size = new size for `renderObject`.
     *
     * Example:
     * ---
     * renderer.renderQuad(background, "Leave", vec2(x, y), vec2(width, height));
     * ---
     *
     * See_also: `renderColorQuad`
     */
    void renderQuad(BaseRenderObject renderObject, in string state,
                    in vec2 position, in vec2 size)
    {
        texAtlasShader.bind();

        renderObject.position = toScreenPosition(position, size);
        renderObject.scaling = size;
        renderObject.updateMatrices();

        with (renderObject.texCoordinates[state]) {
            texAtlasShader.setUniformMatrix("MVP", renderObject.lastMVPMatrix);
            texAtlasShader.setUniformVec2f("texOffset", normOffset);
            texAtlasShader.setUniformVec2f("texSize", normSize);
            texAtlasShader.setUniformFloat("alpha", 1.0f);

            if (renderObject.texture !is null) {
                texAtlasShader.setUniformTexture("texture", renderObject.texture);
            } else {
                texAtlasShader.setUniformTexture("texture", manager.theme.skin);
            }
        }

        renderObject.render(camera);
    }

    /**
     * Renders `renderObject` for particular `state` and update `position` and `size`
     * for `renderObject`. Size will be extracted from texture coordinates.
     */
    void renderQuad(BaseRenderObject renderObject, in string state,
                    in vec2 position)
    {
        const size = renderObject.texCoordinates[state].size;
        renderQuad(renderObject, state, position, size);
    }

    void renderQuad(BaseRenderObject renderObject, in vec2 position) {
        const state = "default";
        const size = renderObject.texCoordinates[state].size;
        renderQuad(renderObject, state, position, size);
    }

    void renderQuad(BaseRenderObject renderObject, in vec2 position, in vec2 size) {
        const state = "default";
        renderQuad(renderObject, state, position, size);
    }

    /**
     * Renders all `renderObjects` as a horizontal chain for particular `state` and
     * update `position` and `size` for chain.
     *
     * Chain will be render in this order: left, center, right.
     *
     * Params:
     *     renderObjects = chain left, center and right parts.
     *     state = uses texture coordinates for state.
     *     position = new chain position.
     *     size = chain size.
     *
     * Example:
     * ---
     * // Creating render objects
     * const states = ["Leave", "Enter", "Click"];
     * const parts = ["left", "center", "right"];
     *
     * foreach (string part; parts) {
     *     // See `rpui.render_factory.RenderFactory.createQuad`
     *     renderFactory.createQuad(chainParts, style, states, key);
     * }
     *
     * // Renders chain
     * renderer.renderHorizontalChain(chainParts, "Leave", absolutePosition, size);
     * ---
     *
     * See_also: `renderChain`, `renderVerticalChain`
     */
    void renderHorizontalChain(BaseRenderObject[string] renderObjects, in string state,
                               in vec2 position, in vec2 size)
    {
        const float leftWidth = renderObjects["left"].texCoordinates[state].size.x;
        const float rightWidth = renderObjects["right"].texCoordinates[state].size.x;
        const float centerWidth = size.x - leftWidth - rightWidth;

        const vec2 leftPos = position;
        const vec2 centerPos = leftPos + vec2(leftWidth, 0);
        const vec2 rightPos = centerPos + vec2(centerWidth, 0);

        renderQuad(renderObjects["left"], state, leftPos, vec2(leftWidth, size.y));
        renderQuad(renderObjects["center"], state, centerPos, vec2(centerWidth, size.y));
        renderQuad(renderObjects["right"], state, rightPos, vec2(rightWidth, size.y));
    }

    /**
     * Renders all `renderObjects` as a horizontal chain for particular `state` and
     * update `position` and `size` for chain. height will be calculated automatically -
     * it will be extracted from texture coordinates of center part.
     *
     * Params:
     *     renderObjects = chain top, middle and bottom parts.
     *     state = uses texture coordinates for state.
     *     position = position of chain.
     *     size = width of chain.
     */
    void renderHorizontalChain(BaseRenderObject[string] renderObjects, in string state,
                               in vec2 position, in float size)
    {
        const float height = renderObjects["center"].texCoordinates[state].size.y;
        renderHorizontalChain(renderObjects, state, position, vec2(size, height));
    }

    /**
     * Renders all `renderObjects` as a vertical chain for particular `state` and
     * update `position` and `size` for chain.
     *
     * Chain will be render in this order: top, middle, bototm.
     *
     * Params:
     *     renderObjects = chain top, middle and bottom parts.
     *     state = uses texture coordinates for state.
     *     position = new chain position.
     *     size = chain size.
     *
     * Example:
     * ---
     * // Creating render objects
     * const states = ["Leave", "Enter", "Click"];
     * const parts = ["top", "middle", "bottom"];
     *
     * foreach (string part; parts) {
     *     // See `rpui.render_factory.RenderFactory.createQuad`
     *     renderFactory.createQuad(chainParts, style, states, key);
     * }
     *
     * // Renders chain
     * renderer.renderVerticalChain(chainParts, "Leave", absolutePosition, size);
     * ---
     */
    void renderVerticalChain(BaseRenderObject[string] renderObjects, in string state,
                             in vec2 position, in vec2 size)
    {
        const float topHeight = renderObjects["top"].texCoordinates[state].size.y;
        const float bottomHeight = renderObjects["bottom"].texCoordinates[state].size.y;
        const float middleHeight = size.y - topHeight - bottomHeight;

        const vec2 topPos = position;
        const vec2 middlePos = topPos + vec2(0, topHeight);
        const vec2 bottomPos = middlePos + vec2(0, middleHeight);

        renderQuad(renderObjects["top"], state, topPos, vec2(size.x, topHeight));
        renderQuad(renderObjects["middle"], state, middlePos, vec2(size.x, middleHeight));
        renderQuad(renderObjects["bottom"], state, bottomPos, vec2(size.x, bottomHeight));
    }

    /**
     * Renders all `renderObjects` as a vertical chain for particular `state` and
     * update `position` and `size` for chain. width will be calculated automatically -
     * it will be extracted from texture coordinates of middle part.
     *
     * Params:
     *     renderObjects = chain top, middle and bottom parts.
     *     state = uses texture coordinates for state.
     *     position = position of chain.
     *     size = height of chain.
     */
    void renderVerticalChain(BaseRenderObject[string] renderObjects, in string state,
                             in vec2 position, in float size)
    {
        const float width = renderObjects["middle"].texCoordinates[state].size.x;
        renderVerticalChain(renderObjects, state, position, vec2(width, size));
    }

    /**
     * Renders horizontal or vertical chain depending on the `orientation`.
     * See_also: `renderHorizontalChain`, `renderVerticalChain`
     */
    void renderChain(T)(BaseRenderObject[string] renderObjects, in Orientation orientation,
                        in string state, in vec2 position, in T size)
    {
        switch (orientation) {
            case Orientation.horizontal:
                renderHorizontalChain(renderObjects, state, position, size);
                break;

            case Orientation.vertical:
                renderVerticalChain(renderObjects, state, position, size);
                break;

            default:
                return;
        }
    }

    /**
     * Renders `text` render object for particular `state` with text color
     * and additional offset placed in rpdl theme data.
     *
     * Params:
     *     text = text render object to be rendered.
     *     state = uses offset and color for state.
     *     position = position of text.
     *     size = region size in which the `text` will be inscribed.
     *
     * Example:
     * ---
     * // See `rpui.render_factory.RenderFactory.createText`
     * textRenderObject = renderFactory.createText("Button", ["Leave"]);
     *
     * textRenderObject.textAlign = Align.center;
     * textRenderObject.textVerticalAlign = VerticalAlign.middle;
     *
     * renderer.renderText(textRenderObject, "Leave", absolutePosition, size);
     * ---
     */
    void renderText(TextRenderObject text, in string state, in vec2 position, in vec2 size) {
        const vec2 textPos = position + text.getOffset(state);
        text.color = text.getColor(state);
        text.scaling = vec2(size);
        text.position = toScreenPosition(textPos, vec2(size));
        text.render(camera);
    }

    void renderText(TextRenderObject text, in vec2 position, in vec2 size) {
        text.scaling = vec2(size);
        text.position = toScreenPosition(position, vec2(size));
        text.render(camera);
    }

    /**
     * Renders `renderObject` colored with `color`.
     *
     * Params:
     *     renderObject = quad to be rendered.
     *     color = quad fill color.
     *     position = position of the quad to be render.
     *     size = size of the quad to be render.
     */
    void renderColoredObject(BaseRenderObject renderObject, in vec4 color,
                             in vec2 position, in vec2 size)
    {
        colorShader.bind();

        renderObject.position = toScreenPosition(position, size);
        renderObject.scaling = size;
        renderObject.updateMatrices();

        colorShader.setUniformMatrix("MVP", renderObject.lastMVPMatrix);
        colorShader.setUniformVec4f("color", color);

        renderObject.render(camera);
    }

package:
    Shader texAtlasShader;
    Shader maskTexAtlasShader;
    Shader colorShader;
    Camera camera;

private:
    Manager manager;
    Application app;

    void initShaders() {
        with (manager.shadersRes) {
            texAtlasShader = addShader("texAtlas", "tex_atlas.glsl");
            maskTexAtlasShader = addShader("maskTexAtlas", "mask_tex_atlas.glsl");
            colorShader = addShader("color", "color.glsl");
        }
    }
}

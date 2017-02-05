module ui.renderer;

import std.conv;
import std.math;
import gapi;
import math.linalg;

import application;
import ui.render_objects;
import ui.manager;


class Renderer {
    this(Manager manager) {
        createShaders();
        this.manager = manager;
        app = Application.getInstance();
    }

    vec2 toScreenPosition(in vec2 position, in vec2 size) {
        return vec2(position.x, app.windowHeight - size.y - position.y);
    }

    void renderPart(BaseRenderObject renderObject, in string state,
                    in vec2 position, in vec2 size)
    {
        renderObject.position = toScreenPosition(position, size);
        renderObject.scaling = size;

        with (renderObject.texCoordinates[state]) {
            p_texAtlasShader.setUniformMatrix("MVP", renderObject.lastMVPMatrix);
            p_texAtlasShader.setUniformTexture("texture", manager.theme.skin);
            p_texAtlasShader.setUniformVec2f("texOffset", normOffset);
            p_texAtlasShader.setUniformVec2f("texSize", normSize);
            p_texAtlasShader.setUniformFloat("alpha", 1.0f);
        }

        renderObject.render(camera);
    }

    void renderPartsHorizontal(BaseRenderObject[string] renderObjects, in string state,
                               in vec2i position, in vec2i size)
    {
        p_texAtlasShader.bind();

        const float leftWidth = renderObjects["left"].texCoordinates[state].size.x;
        const float rightWidth = renderObjects["right"].texCoordinates[state].size.x;
        const float centerWidth = size.x - leftWidth - rightWidth;

        const uint height = size.y;

        const vec2 leftPos = position;
        const vec2 centerPos = leftPos + vec2(leftWidth, 0);
        const vec2 rightPos = centerPos + vec2(centerWidth, 0);

        renderPart(renderObjects["left"], state, leftPos, vec2(leftWidth, height));
        renderPart(renderObjects["center"], state, centerPos, vec2(centerWidth, height));
        renderPart(renderObjects["right"], state, rightPos, vec2(rightWidth, height));
    }

    @property gapi.Camera camera() { return p_camera; }
    @property void camera(gapi.Camera val) { p_camera = val; }
    @property gapi.Shader texAtlasShader() { return p_texAtlasShader; }
    @property gapi.Shader maskTexAtlasShader() { return p_maskTexAtlasShader; }
    @property gapi.Shader colorizeShader() { return p_colorizeShader; }

private:
    gapi.Shader p_texAtlasShader;
    gapi.Shader p_maskTexAtlasShader;
    gapi.Shader p_colorizeShader;
    gapi.Camera p_camera;

    Manager manager;
    Application app;

    void createShaders() {
        p_texAtlasShader = Shader.createFromFile("tex_atlas.glsl");
        p_maskTexAtlasShader = Shader.createFromFile("mask_tex_atlas.glsl");
        p_colorizeShader = Shader.createFromFile("colorize.glsl");
    }
}

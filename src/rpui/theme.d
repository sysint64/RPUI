module rpui.theme;

import std.path;
import std.file;

import rpdl;

import gapi.font;
import gapi.texture;
import gapi.shader;

import rpui.paths;

struct Theme {
    RpdlTree tree;
    const Texture2D skin;
    const Font regularFont;
    ThemeShaders shaders;
}

struct ThemeShaders {
    ShaderProgram textureAtlasShader;
}

Theme createThemeByName(in string theme) {
    const paths = createPathes();
    const dir = buildPath(paths.resources, "ui", "themes", theme);

    auto tree = new RpdlTree(dir);
    tree.load("theme.rdl");

    const skinPath = buildPath(dir, "controls.png");
    const skin = createTexture2DFromFile(skinPath);

    const regularFontFileName = tree.data.getString("General.regularFont.0");
    const font = createFontFromFile(regularFontFileName);

    return Theme(tree, skin, font, createThemeShaders());
}

private ThemeShaders createThemeShaders() {
    const vertexSource = readText(buildPath("res", "shaders", "transform_vertex.glsl"));
    const vertexShader = createShader("transform vertex shader", ShaderType.vertex, vertexSource);

    const texAtalsFragmentSource = readText(buildPath("res", "shaders", "texture_atlas_fragment.glsl"));
    const texAtlasFragmentShader = createShader("texture atlas fragment shader", ShaderType.fragment, texAtalsFragmentSource);
    auto texAtlasShader = createShaderProgram("texture atlas program", [vertexShader, texAtlasFragmentShader]);

    return ThemeShaders(texAtlasShader);
}

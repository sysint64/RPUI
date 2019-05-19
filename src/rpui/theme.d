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
    Font regularFont;
    const int regularFontSize;
    ThemeShaders shaders;
}

struct ThemeShaders {
    ShaderProgram textureAtlasShader;
    ShaderProgram textShader;
    ShaderProgram transformShader;
}

Theme createThemeByName(in string theme) {
    const paths = createPathes();
    const dir = buildPath(paths.resources, "ui", "themes", theme);

    auto tree = new RpdlTree(dir);
    tree.load("theme.rdl");

    const skinPath = buildPath(dir, "controls.png");
    const skin = createTexture2DFromFile(skinPath);

    const regularFontFileName = tree.data.getString("General.regularFont.0");
    const regularFontSize = tree.data.getInteger("General.regularFont.1");
    Font font = createFontFromFile(buildPath(paths.resources, "fonts", regularFontFileName));

    return Theme(tree, skin, font, regularFontSize, createThemeShaders());
}

private ThemeShaders createThemeShaders() {
    const vertexSource = readText(buildPath("res", "shaders", "transform_vertex.glsl"));
    const vertexShader = createShader("transform vertex shader", ShaderType.vertex, vertexSource);

    const texAtalsFragmentSource = readText(buildPath("res", "shaders", "texture_atlas_fragment.glsl"));
    const texAtlasFragmentShader = createShader("texture atlas fragment shader", ShaderType.fragment, texAtalsFragmentSource);
    auto texAtlasShader = createShaderProgram("texture atlas program", [vertexShader, texAtlasFragmentShader]);

    const fragmentColorSource = readText(buildPath("res", "shaders", "color_fragment.glsl"));
    const fragmentColorShader = createShader("color fragment shader", ShaderType.fragment, fragmentColorSource);

    auto textShader = createShaderProgram("text program", [vertexShader, fragmentColorShader]);

    const textureFragmentSource = readText(buildPath("res", "shaders", "texture_fragment.glsl"));
    const textureFragmentShader = createShader("texture fragment shader", ShaderType.fragment, textureFragmentSource);

    auto transformShader = createShaderProgram("transform program", [vertexShader, textureFragmentShader]);

    return ThemeShaders(texAtlasShader, textShader, transformShader);
}

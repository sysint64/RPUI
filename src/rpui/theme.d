module rpui.theme;

import std.path;
import std.file;

import rpdl;

import gapi.font;
import gapi.texture;
import gapi.shader;

import rpui.paths;

struct Theme {
    string name;
    RpdlTree tree;
    Texture2D skin;
    Font regularFont;
    int regularFontSize;
    ThemeShaders shaders;
}

struct ThemeShaders {
    ShaderProgram textureAtlasShader;
    ShaderProgram textShader;
    ShaderProgram transformShader;
    ShaderProgram colorShader;
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

    return Theme(theme, tree, skin, font, regularFontSize, createThemeShaders());
}

private ThemeShaders createThemeShaders() {
    return ThemeShaders(
        createSimpleShader("tex atlas", "transform_vertex.glsl", "texture_atlas_fragment.glsl"),
        createSimpleShader("text", "transform_vertex.glsl", "text_fragment.glsl"),
        createSimpleShader("transform", "transform_vertex.glsl", "texture_fragment.glsl"),
        createSimpleShader("color", "transform_vertex.glsl", "color_fragment.glsl"),
    );
}

private ShaderProgram createSimpleShader(in string name, in string vertex, in string fragment) {
    const vertexSource = readText(buildPath("res", "shaders", vertex));
    const vertexShader = createShader(vertex, ShaderType.vertex, vertexSource);

    const fragmentSource = readText(buildPath("res", "shaders", fragment));
    const fragmentShader = createShader(fragment, ShaderType.fragment, fragmentSource);

    return createShaderProgram(name ~ " shader program", [vertexShader, fragmentShader]);
}

module rpui.render.components_factory;

import std.traits;
import std.string;

import rpdl;

import gapi.texture;
import gapi.geometry;
import gapi.geometry_quad;
import gapi.shader;
import gapi.text;
import gapi.vec;

import rpui.render.components;
import rpui.gapi_rpdl_exts;
import rpui.theme;
import rpui.primitives;

StatefulChain createStatefulChainFromRdpl(
    Theme theme,
    in Orientation orientation,
    in string style,
    immutable State[] states = [EnumMembers!State]
) {
    StatefulChain chain;

    immutable chainParts = orientation == Orientation.horizontal
        ? horizontalChainParts
        : verticalChainParts;

    foreach (immutable part; chainParts) {
        chain.parts[part] = createUiSkinTextureQuad(theme);

        foreach (immutable state; states) {
            const texCoords = createOriginalWithNormilizedTextureCoordsFromRdpl(
                theme,
                style ~ "." ~ getStateRdplName(state) ~ "." ~ getChainPartRdplName(part)
            );
            chain.texCoords[state][part] = texCoords.normilizedTexCoords;
            chain.widths[part] = orientation == Orientation.horizontal
                ? texCoords.originalTexCoords.size.x
                : texCoords.originalTexCoords.size.y;
        }
    }

    return chain;
}

Chain createChainFromRdpl(Theme theme, in Orientation orientation, in string style) {
    Chain chain;

    immutable chainParts = orientation == Orientation.horizontal
        ? horizontalChainParts
        : verticalChainParts;

    foreach (immutable part; chainParts) {
        chain.parts[part] = createUiSkinTextureQuad(theme);

        const texCoords = createOriginalWithNormilizedTextureCoordsFromRdpl(
            theme,
            style ~ "." ~ getChainPartRdplName(part)
        );

        chain.texCoords[part] = texCoords.normilizedTexCoords;
        chain.widths[part] = texCoords.originalTexCoords.size.x;
        chain.height = texCoords.originalTexCoords.size.y;
    }

    return chain;
}

Block createBlockFromRdpl(Theme theme, in string style) {
    Block block;

    block.topChain = createChainFromRdpl(theme, Orientation.horizontal, style ~ ".Top");
    block.middleChain = createChainFromRdpl(theme, Orientation.horizontal, style ~ ".Middle");
    block.bottomChain = createChainFromRdpl(theme, Orientation.horizontal, style ~ ".Bottom");

    block.widths[BlockRow.top] = block.topChain.widths;
    block.widths[BlockRow.middle] = block.topChain.widths;
    block.widths[BlockRow.bottom] = block.topChain.widths;

    block.heights[BlockRow.top] = block.topChain.height;
    block.heights[BlockRow.middle] = block.topChain.height;
    block.heights[BlockRow.bottom] = block.topChain.height;

    return block;
}

TextureQuad createUiSkinTextureQuad(in Theme theme) {
    TextureQuad quad;
    quad.geometry = createGeometry();
    quad.texture = theme.skin;

    return quad;
}

StatefulTexAtlasTextureQuad createStatefulTexAtlasTextureQuadFromRdpl(
    Theme theme,
    in string style,
    in string name,
    immutable State[] states = [EnumMembers!State]
) {
    StatefulTexAtlasTextureQuad quad;

    quad.geometry = createGeometry();
    quad.texture = theme.skin;

    foreach (immutable state; states) {
        const texCoords = createOriginalWithNormilizedTextureCoordsFromRdpl(
            theme,
            style ~ "." ~ getStateRdplName(state) ~ "." ~ name
        );
        quad.texCoords[state] = texCoords;
    }

    return quad;
}

TexAtlasTextureQuad createTexAtlasTextureQuadFromRdpl(
    Theme theme,
    in string style,
    in string name
) {
    TexAtlasTextureQuad quad;

    quad.geometry = createGeometry();
    quad.texture = theme.skin;
    quad.texCoords = createOriginalWithNormilizedTextureCoordsFromRdpl(
        theme,
        style ~ "." ~ name
    );

    return quad;
}

TexAtlasTextureQuad createTexAtlasTextureQuad(
    Texture2D texture,
    Texture2DCoords texCoords
) {
    return TexAtlasTextureQuad(
        createGeometry(),
        texture,
        OriginalWithNormilizedTextureCoords(texCoords, texCoords)
    );
}

OriginalWithNormilizedTextureCoords createOriginalWithNormilizedTextureCoordsFromRdpl(
    Theme theme,
    in string style,
) {
    const textCoord = theme.tree.data.getTexCoord(style);
    const normilized = normilizeTexture2DCoords(textCoord, theme.skin);

    return OriginalWithNormilizedTextureCoords(textCoord, normilized);
}

Texture2DCoords createNormilizedTextureCoordsFromRdpl(
    Theme theme,
    in string style,
) {
    const textCoord = theme.tree.data.getTexCoord(style);
    return normilizeTexture2DCoords(textCoord, theme.skin);
}

UiText createUiTextFromRdpl(
    Theme theme,
    in string style,
    in string name
) {
    UiText text;

    text.render = createUiTextRenderObject();
    text.attrs = createTextAttributesFromRdpl(theme, style ~ "." ~ name);

    return text;
}

StatefulUiText createStatefulUiTextFromRdpl(
    Theme theme,
    in string style,
    in string name,
    immutable State[] states = [EnumMembers!State]
) {
    StatefulUiText text;
    text.render = createUiTextRenderObject();

    foreach (immutable state; states) {
        text.attrs[state] = createTextAttributesFromRdpl(
            theme,
            style ~ "." ~ getStateRdplName(state) ~ "." ~ name
        );
    }

    return text;
}

UiTextAttributes createTextAttributesFromRdpl(Theme theme, in string style) {
    UiTextAttributes attrs;

    attrs.color = theme.tree.data.getNormColor(style ~ ".color");
    attrs.offset = theme.tree.data.optVec2f(style ~ ".offset", vec2(0, 0));
    attrs.fontSize = theme.tree.data.optInteger(style ~ ".fontSize.0", theme.regularFontSize);
    attrs.textAlign = theme.tree.data.optEnum(style ~ ".textAlign.0", Align.center);
    attrs.textVerticalAlign = theme.tree.data.optEnum(style ~ ".textVerticalAlign.0", VerticalAlign.middle);
    // TODO: read from rdpl
    attrs.font = theme.regularFont;

    return attrs;
}

UiTextRender createUiTextRenderObject() {
    return UiTextRender(createGeometry(), createText());
}

Geometry createGeometry() {
    Geometry geometry;

    geometry.indicesBuffer = createIndicesBuffer(quadIndices);
    geometry.verticesBuffer = createVector2fBuffer(quadVertices);
    geometry.texCoordsBuffer = createVector2fBuffer(quadTexCoords);

    geometry.vao = createVAO();
    bindVAO(geometry.vao);

    createVector2fVAO(geometry.verticesBuffer, inAttrPosition);
    createVector2fVAO(geometry.texCoordsBuffer, inAttrTextCoords);

    return geometry;
}

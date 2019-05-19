module rpui.render_factory;

import std.traits;

import rpdl;

import gapi.texture;
import gapi.geometry;
import gapi.geometry_quad;
import gapi.shader;
import gapi.text;
import gapi.vec;

import rpui.render_objects;
import rpui.gapi_rpdl_exts;
import rpui.theme;

StatefulHorizontalChain createStatefulHorizontalChainFromRdpl(Theme theme, in string style) {
    StatefulHorizontalChain chain;

    foreach (immutable part; [EnumMembers!ChainPart]) {
        chain.parts[part] = createChainPart(theme);

        foreach (immutable state; [EnumMembers!State]) {
            const texCoords = createOriginalWithNormilizedTextureCoordsFromRdpl(
                theme,
                style ~ "." ~ getStateRdplName(state) ~ "." ~ getChainPartRdplName(part)
            );
            chain.texCoords[state][part] = texCoords.normilizedTexCoords;
            chain.widths[part] = texCoords.originalTexCoords.size.x;
        }
    }

    return chain;
}

HorizontalChain createHorizontalChainFromRdpl(Theme theme, in string style) {
    HorizontalChain chain;

    foreach (immutable part; [EnumMembers!ChainPart]) {
        chain.parts[part] = createChainPart(theme);

        const texCoords = createOriginalWithNormilizedTextureCoordsFromRdpl(
            theme,
            style ~ "." ~ getChainPartRdplName(part)
        );

        chain.texCoords[part] = texCoords.normilizedTexCoords;
        chain.widths[part] = texCoords.originalTexCoords.size.x;
    }

    return chain;
}

TextureQuad createChainPart(in Theme theme) {
    TextureQuad quad;
    quad.geometry = createGeometry();
    quad.texture = theme.skin;

    return quad;
}

OriginalWithNormilizedTextureCoords createOriginalWithNormilizedTextureCoordsFromRdpl(
    Theme theme,
    in string style,
) {
    const textCoord = theme.tree.data.getTexCoord(style);
    const normilized = normilizeTexture2DCoords(textCoord, theme.skin);

    return OriginalWithNormilizedTextureCoords(textCoord, normilized);
}

StatefulUiText createStatefulUiText(Theme theme, in string style) {
    StatefulUiText text;
    text.render = createUiTextRenderObjec();

    foreach (immutable state; [EnumMembers!State]) {
        text.attrs[state] = createTextAttributesFromRdpl(
            theme,
            style ~ "." ~ getStateRdplName(state)
        );
    }

    return text;
}

UiTextAttributes createTextAttributesFromRdpl(Theme theme, in string style, in string prefix = "text") {
    UiTextAttributes attrs;

    attrs.color = theme.tree.data.getNormColor(style ~ "." ~ prefix ~ "Color");
    attrs.offset = theme.tree.data.optVec2f(style ~ "." ~ prefix ~ "Offset", vec2(0, 0));
    attrs.fontSize = theme.tree.data.optInteger(style ~ "." ~ prefix ~ "FontSize.0", theme.regularFontSize);
    // attrs.caption = theme.;
    // attrs.textAlign = theme.;
    // attrs.textVerticalAlign = theme.;
    // attrs.color = vec4(0, 0, 0, 1);
    // attrs.offset = vec2(0, -1);

    return attrs;
}

UiTextRender createUiTextRenderObjec() {
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

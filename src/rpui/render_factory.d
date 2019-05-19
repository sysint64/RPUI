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

TextureQuad createChainPartFromRdpl(in Theme theme) {
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

UiTextAttributes createTextAttributesFromRdpl(Theme theme, in string style) {
    UiTextAttributes attrs;

    attrs.color = vec4(0, 0, 0, 1);
    attrs.offset = vec2(0, -1);

    return attrs;
}

UiText createUiText() {
    return UiText(createGeometry(), createText());
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

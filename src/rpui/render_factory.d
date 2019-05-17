module rpui.render_factory;

import std.traits;

import rpdl;

import gapi.texture;
import gapi.geometry;
import gapi.geometry_quad;
import gapi.shader;

import rpui.render_objects;
import rpui.gapi_rpdl_exts;
import rpui.theme;

StatefulTextureQuad createStatefulChainPartFromRdpl(Theme theme, in string style, in ChainPart part) {
    StatefulTextureQuad quad;
    quad.geometry = createGeometry();
    quad.texture = theme.skin;

    foreach (immutable state; [EnumMembers!State]) {
        const path = style ~ "." ~ getStateRdplName(state) ~ "." ~ getChainPartRdplName(part);
        const textCoord = theme.tree.data.getTexCoord(path);
        quad.texCoords[state] = normilizeTexture2DCoords(textCoord, theme.skin);
    }

    return quad;
}

TextureQuad createChainPartFromRdpl(Theme theme, in string style, in ChainPart part) {
    TextureQuad quad;
    quad.geometry = createGeometry();
    quad.texture = theme.skin;

    const path = style ~ "." ~ getChainPartRdplName(part);
    const textCoord = theme.tree.data.getTexCoord(path);
    quad.texCoords = normilizeTexture2DCoords(textCoord, theme.skin);

    return quad;
}

Geometry createGeometry() {
    Geometry geometry;

    geometry.indicesBuffer = createIndicesBuffer(quadIndices);
    geometry.verticesBuffer = createVector2fBuffer(centeredQuadVertices);
    geometry.texCoordsBuffer = createVector2fBuffer(quadTexCoords);

    geometry.vao = createVAO();
    bindVAO(geometry.vao);

    createVector2fVAO(geometry.verticesBuffer, inAttrPosition);
    createVector2fVAO(geometry.texCoordsBuffer, inAttrTextCoords);

    return geometry;
}

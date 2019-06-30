module rpui.render.render_system;

import std.container.array;
import rpui.render.transforms_system;

import rpui.theme;
import rpui.render.transforms;
import rpui.render.renderer;
import rpui.render.components;
import rpui.math;
import gapi.texture;

struct TexAtlasTextureQuadInput {
    size_t entityId;
    Geometry geometry;
    Texture2D texture;
    Texture2DCoords texCoords;
    QuadTransforms transforms;
}

final class NewRenderSystem {
    // Array!QuadTransformsResult quadsResult;
    // Array!HorizontalChainTransforms horizontalChainsResult;
    // Array!HorizontalChainTransforms verticalChainsResult;
    // Array!UiTextTransforms textsResult;
    private NewTransformsSystem transformsSystem;

    void onRender(in RenderEntity entity) {
        switch (entity.renderType) {
            case RenderType.textureQuad:
                // renderTextureQuad();
                break;

            default:
                break;
        }
    }

    // private void renderTextureQuad(in QuadTransformsResult result, ) {

    // }
}

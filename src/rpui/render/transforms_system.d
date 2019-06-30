module rpui.render.transforms_system;

import std.container.array;
import std.experimental.allocator.building_blocks.region;

import rpui.events;
import rpui.render.transforms;
import rpui.render.components;
import rpui.math;

struct QuadTransformsInput {
    size_t entityId;
    CameraView cameraView;
    vec2 position;
    vec2 size;
}

struct ChainTransformsInput {
    size_t entityId;
    float[ChainPart] widths;
    CameraView cameraView;
    vec2 position;
    vec2 size;
}

struct QuadTransformsResult {
    size_t entityId;
    QuadTransforms transforms;
}

struct UiTextTransformsInput {
    CameraView cameraView;
}

enum RenderType {
    colorQuad,
    textureQuad,
    horizontalChain,
    verticalChain,
    text,
}

union RenderData {
    TextureQuad textureQuad;
    TexAtlasTextureQuad texAtlasTextureQuad;
}

union TransformsData {
}

struct RenderEntity {
    size_t id;
    RenderType renderType;
    RenderData renderData;
    TransformsData transforms;
}

final class NewRenderer {
    NewTransformsSystem transformsSystem;
    Array!RenderEntity entities;

    void onPreRender() {
        // with (transformsSystem) {
        //     quadsInput.clear();
        //     horizontalChainsInput.clear();
        //     verticalChainsInput.clear();
        //     textsInput.clear();
        // }
    }

    void queryRenderTextureQuad(QuadTransformsInput input, in TexAtlasTextureQuad quad) {
        // auto test = Algebraic!(const(TexAtlasTextureQuad))(quad);
        const RenderData renderData = { texAtlasTextureQuad: quad };
        const entity = RenderEntity(entities.length, RenderType.textureQuad, renderData);

        entities.insert(entity);
        transformsSystem.quadsInput.insert(input);
    }

    void onRender() {
    }
}

final class NewTransformsSystem {
    Array!QuadTransformsInput quadsInput;
    Array!ChainTransformsInput horizontalChainsInput;
    Array!ChainTransformsInput verticalChainsInput;
    Array!UiTextTransformsInput textsInput;

    Array!QuadTransformsResult quadsResult;
    Array!HorizontalChainTransforms horizontalChainsResult;
    Array!HorizontalChainTransforms verticalChainsResult;
    Array!UiTextTransforms textsResult;

    void onProgress() {
        quadsResult.length = quadsInput.length;
        horizontalChainsResult.length = horizontalChainsInput.length;
        textsResult.length = textsResult.length;

        for (int i = 0; i < quadsInput.length; ++i) {
            quadsResult[i].entityId = quadsInput[i].entityId;
            quadsResult[i].transforms = updateQuadTransforms(
                quadsInput[i].cameraView,
                quadsInput[i].position,
                quadsInput[i].size,
            );
        }

        for (int i = 0; i < horizontalChainsInput.length; ++i) {
            horizontalChainsResult[i] = updateHorizontalChainTransforms(
                horizontalChainsInput[i].widths,
                horizontalChainsInput[i].cameraView,
                horizontalChainsInput[i].position,
                horizontalChainsInput[i].size,
            );
        }

        for (int i = 0; i < verticalChainsInput.length; ++i) {
            verticalChainsResult[i] = updateVerticalChainTransforms(
                verticalChainsInput[i].widths,
                verticalChainsInput[i].cameraView,
                verticalChainsInput[i].position,
                verticalChainsInput[i].size,
            );
        }

        quadsInput.clear();
    }
}

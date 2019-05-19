module rpui.measure;

import std.math;

import gapi.vec;
import gapi.font;
import gapi.text;
import gapi.transform;
import gapi.texture;

import rpui.widget;
import rpui.render_objects;
import rpui.alignment;

private vec2 toScreenPosition(in float windowHeight, in vec2 position, in float height) {
    return vec2(floor(position.x), floor(windowHeight - height - position.y));
}

QuadTransforms updateQuadTransforms(
    in CameraView cameraView,
    in vec2 position,
    in vec2 size
) {
    QuadTransforms transforms;

    with (transforms) {
        transform.position = toScreenPosition(cameraView.viewportHeight, position, size.y);
        transform.scaling = size;
        modelMatrix = create2DModelMatrix(transform);
        mvpMatrix = cameraView.mvpMatrix * modelMatrix;
    }

    return transforms;
}

HorizontalChainTransforms updateHorizontalChainTransforms(
    in float[ChainPart] partWidths,
    in CameraView cameraView,
    in vec2 position,
    in vec2 size,
    in Widget.PartDraws partDraws
) {
    HorizontalChainTransforms transforms;

    auto leftSize = vec2(partWidths[ChainPart.left], size.y);
    auto rightSize = vec2(partWidths[ChainPart.right], size.y);
    auto centerSize = vec2(size.x - leftSize.x - rightSize.x, size.y);

    auto leftPos = position;
    auto centerPos = leftPos + vec2(leftSize.x, 0);
    auto rightPos = centerPos + vec2(centerSize.x, 0);

    switch (partDraws) {
        case Widget.PartDraws.left:
            centerSize.x += rightSize.x;
            break;

        case Widget.PartDraws.center:
            centerPos = position;
            centerSize = size;
            break;

        case Widget.PartDraws.right:
            centerPos = leftPos;
            centerSize.x += leftSize.x;
            break;

        default:
            // Nothing
    }

    with (transforms) {
        quadTransforms[ChainPart.left] = updateQuadTransforms(cameraView, leftPos, leftSize);
        quadTransforms[ChainPart.center] = updateQuadTransforms(cameraView, centerPos, centerSize);
        quadTransforms[ChainPart.right] = updateQuadTransforms(cameraView, rightPos, rightSize);
    }

    return transforms;
}

UiTextTransforms updateUiTextTransforms(
    UiTextRender* uiText,
    Font* font,
    in UiTextAttributes attrs,
    in CameraView cameraView,
    in vec2 position,
    in vec2 size = vec2(0, 0)
) {
    UiTextTransforms measure;

    UpdateTextInput updateTextInput = {
        textSize: attrs.fontSize,
        font: font,
        text: attrs.caption
    };

    const textUpdateResult = updateTextureText(&uiText.text, updateTextInput);

    uiText.texture = textUpdateResult.texture;
    measure.size = textUpdateResult.surfaceSize;

    vec2 textPosition = position;

    if (size != vec2(0, 0)) {
        textPosition.x += alignBox(attrs.textAlign, measure.size.x, size.x);
        textPosition.y += verticalAlignBox(attrs.textVerticalAlign, measure.size.y, size.y);
    }

    const Transform2D textTransform = {
        position: toScreenPosition(cameraView.viewportHeight, textPosition, textUpdateResult.surfaceSize.y),
        scaling: textUpdateResult.surfaceSize
    };

    measure.mvpMatrix = cameraView.mvpMatrix * create2DModelMatrix(textTransform);
    return measure;
}

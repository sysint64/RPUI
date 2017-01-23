module ui.render_helper_methods;


mixin template RenderHelperMethods() {
    void renderPart(gapi.BaseObject renderObject, in size_t coodIndex,
                    in vec2i position, in vec2i size)
    {
    }

    void renderPartsHorizontal(gapi.BaseObject[3] renderObjects, in size_t[3] coordIndices,
                               in vec2i position, in vec2i size)
    {
        const size_t leftIndex = coordIndices[0];
        const size_t centerIndex = coordIndices[1];
        const size_t rightIndex = coordIndices[2];

        const uint leftWidth = precomputeCoords[leftIndex].size.x;
        const uint rightWidth = precomputeCoords[leftIndex].size.x;
        const uint centerWidth = size.x - leftWidth - rightWidth;

        const uint height = size.y;

        const int leftPos = position;
        const int centerPos = leftPos + leftWidth;
        const int rightPos = centerPos + centerWidth;

        renderPart(renderObjects[0], leftIndex, leftPos, vec2i(leftWidth, height));
        renderPart(renderObjects[1], centerIndex, centerPos, vec2i(centerWidth, height));
        renderPart(renderObjects[2], rightIndex, rightPos, vec2i(rightWidth, height));
    }
}

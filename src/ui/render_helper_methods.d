module ui.render_helper_methods;


mixin template RenderHelperMethods() {
    void renderPart(gapi.BaseObject renderObject, in size_t coodIndex,
                    in vec2 position, in vec2 size)
    {
        renderObject.position = position;
        renderObject.scaling = size;
        renderObject.render(camera);
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

        const vec2 leftPos = position;
        const vec2 centerPos = leftPos + vec2(leftWidth, 0);
        const vec2 rightPos = centerPos + vec2(centerWidth, 0);

        renderPart(renderObjects[0], leftIndex, leftPos, vec2(leftWidth, height));
        renderPart(renderObjects[1], centerIndex, centerPos, vec2(centerWidth, height));
        renderPart(renderObjects[2], rightIndex, rightPos, vec2(rightWidth, height));
    }
}

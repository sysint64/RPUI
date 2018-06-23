module rpui.widgets.text_input.render_data;

import rpui.theme;
import rpui.render_factory;
import rpui.render_objects;
import math.linalg;

struct RenderData {
    BaseRenderObject[string] skinRenderObjects;
    BaseRenderObject[string] skinFocusRenderObjects;
    BaseRenderObject leftArrowRenderObject;
    BaseRenderObject rightArrowRenderObject;
    TextRenderObject textRenderObject;
    BaseRenderObject carriageRenderObject;
    TextRenderObject selectedTextRenderObject;
    BaseRenderObject selectRegionRenderObject;

    vec2 focusOffsets;
    float focusResize;
    float textLeftMargin;
    float textRightMargin;
    float textTopMargin;
    float carriageBoundary;

    vec4 selectColor;
    vec4 selectedTextColor;
    float selectRegionHeight;
    vec2 selectRegionOffset;

    vec2 arrowOffsets;
    float arrowsAreaWidth;

    void onCreate(RenderFactory renderFactory, Theme theme, in string style) {
        const states = ["Leave", "Enter", "Click"];
        const keys = ["left", "center", "right"];

        foreach (string key; keys) {
            renderFactory.createQuad(skinRenderObjects, style, states, key);
            renderFactory.createQuad(skinFocusRenderObjects, style, "Focus", key);
        }

        renderFactory.createQuad(selectRegionRenderObject);
        renderFactory.createQuad(leftArrowRenderObject, style, states, "arrowLeft");
        renderFactory.createQuad(rightArrowRenderObject, style, states, "arrowRight");

        const focusKey = style ~ ".Focus";

        with (theme.tree) {
            focusOffsets = data.getVec2f(focusKey ~ ".offsets.0");
            focusResize = data.getNumber(focusKey ~ ".offsets.1");

            textRenderObject = renderFactory.createText(style, states);
            textLeftMargin = data.getNumber(style ~ ".textLeftMargin.0");
            textRightMargin = data.getNumber(style ~ ".textRightMargin.0");
            textTopMargin = data.getNumber(style ~ ".textTopMargin.0");

            carriageRenderObject = renderFactory.createQuad(style ~ ".stick");
            carriageBoundary = data.getNumber(style ~ ".carriageBoundary.0");

            selectColor = data.getNormColor(style ~ ".selectColor");
            selectRegionHeight = data.getNumber(style ~ ".selectRegionHeight.0");
            selectRegionOffset = data.getVec2f(style ~ ".selectRegionOffset");
            selectedTextColor = data.getNormColor(style ~ ".selectedTextColor");

            selectedTextRenderObject = renderFactory.createText();
            selectedTextRenderObject.color = selectedTextColor;

            arrowOffsets = data.getVec2f(style ~ ".arrowOffsets");
            arrowsAreaWidth = data.getNumber(style ~ ".arrowsAreaWidth.0");
        }
    }
}

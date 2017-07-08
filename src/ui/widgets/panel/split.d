module ui.widgets.panel.split;

import gapi;
import rpdl;
import math.linalg;
import basic_types;

import ui.theme;
import ui.render_objects;
import ui.render_factory;
import ui.renderer;

import ui.widgets.panel.widget;


package struct Split {
    BaseRenderObject borderRenderObject;
    BaseRenderObject borderInnerRenderObject;

    vec4[string] colors;
    bool isClick = false;
    bool isEnter = false;
    float thickness = 1;
    float cursorRangeSize = 8;
    Rect cursorRangeRect;
    vec2 borderPosition;
    vec2 borderInnerPosition;
    vec2 size;
    Panel panel;
    Renderer renderer;

    string state(in bool innerColor, in bool useBlackColor = false) const {
        const string color = innerColor ? "innerColor" : "borderColor";
        return panel.blackSplit || useBlackColor ? "Split.Dark." ~ color : "Split.Light." ~ color;
    }

    void onCreate(Panel panel, Theme theme, Renderer renderer) {
        this.panel = panel;
        this.renderer = renderer;
        const string style = panel.style;
        RPDLTree styleData = theme.data;

        panel.renderFactory.createQuad(borderRenderObject);
        panel.renderFactory.createQuad(borderInnerRenderObject);

        thickness = styleData.getNumber(style ~ ".Split.thickness.0");

        void addColor(in string key) {
            colors[key] = styleData.getNormColor(style ~ "." ~ key);
        }

        addColor(state(false, false));
        addColor(state(false, true));
        addColor(state(true , false));
        addColor(state(true , true));
    }

    // Calculate split borderPosition, innerPosition and size
    void calculate() {
        if (!panel.resizable && !panel.showSplit)
            return;

        switch (panel.regionAlign) {
            case RegionAlign.top:
                borderPosition = panel.absolutePosition + vec2(0, panel.size.y - thickness);
                borderInnerPosition = borderPosition - vec2(0, thickness);
                size = vec2(panel.size.x, thickness);
                break;

            case RegionAlign.bottom:
                borderPosition = panel.absolutePosition;
                borderInnerPosition = borderPosition + vec2(0, thickness);
                size = vec2(panel.size.x, thickness);
                break;

            case RegionAlign.left:
                borderPosition = panel.absolutePosition + vec2(panel.size.x - thickness, 0);
                borderInnerPosition = borderPosition - vec2(thickness, 0);
                size = vec2(thickness, panel.size.y);
                break;

            case RegionAlign.right:
                borderPosition = panel.absolutePosition;
                borderInnerPosition = borderPosition + vec2(thickness, 0);
                size = vec2(thickness, panel.size.y);
                break;

            default:
                return;
        }
    }

    void render() {
        if (!panel.showSplit)
            return;

        with (renderer) {
            renderColorQuad(
                borderRenderObject,
                colors[state(false)],
                borderPosition,
                size
            );
            renderColorQuad(
                borderInnerRenderObject,
                colors[state(true)],
                borderInnerPosition,
                size
            );
        }
    }
}

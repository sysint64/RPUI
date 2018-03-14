/**
 * Copyright: © 2017 RedGoosePaws
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 * Authors: Andrey Kabylin
 */

module rpui.widgets.panel.split;

import gapi;
import rpdl;
import math.linalg;
import basic_types;

import rpui.theme;
import rpui.render_objects;
import rpui.render_factory;
import rpui.renderer;

import rpui.widgets.panel;

/// Panel split line part.
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

    /// Get rpdl relative selector depends of color.
    string state(in bool innerColor, in bool useBlackColor = false) const {
        const string color = innerColor ? "innerColor" : "borderColor";
        return panel.blackSplit || useBlackColor ? "Split.Dark." ~ color : "Split.Light." ~ color;
    }

    void onCreate(Panel panel, Theme theme, Renderer renderer) {
        this.panel = panel;
        this.renderer = renderer;
        const string style = panel.style;
        auto styleData = theme.tree.data;

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

    /// Calculate split borderPosition, innerPosition and size.
    void calculate() {
        if (!panel.userCanResize && !panel.showSplit)
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
            renderColoredObject(
                borderRenderObject,
                colors[state(false)],
                borderPosition,
                size
            );
            renderColoredObject(
                borderInnerRenderObject,
                colors[state(true)],
                borderInnerPosition,
                size
            );
        }
    }
}

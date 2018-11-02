/**
 * Copyright: © 2017 Andrey Kabylin
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 */

module rpui.widgets.panel.scroll_button;

import std.typecons;

import gapi;
import rpdl;
import application;
import math.linalg;
import basic_types;

import rpui.theme;
import rpui.scroll;
import rpui.render_objects;
import rpui.renderer;

import rpui.widgets.panel;

/// Panel scroll button part.
package struct ScrollButton {
    Application app;

    BaseRenderObject[string] backgroundRenderObjects;
    BaseRenderObject[string] buttonRenderObjects;
    ScrollController scrollController;
    float width;

    bool isEnter = false;
    bool isClick = false;
    bool visible = false;

    Renderer renderer;
    Orientation orientation;
    Panel panel;
    RpdlNode styleData;
    vec2 buttonOffset;
    float buttonSize;

    this(in Orientation orientation) {
        this.orientation = orientation;
    }

    /// Update `scrollController` properties
    void updateController() {
        const float[Orientation] widgetRegionSizes = [
            Orientation.horizontal: panel.extraInnerOffset.left + panel.extraInnerOffset.right,
            Orientation.vertical: panel.extraInnerOffset.top + panel.extraInnerOffset.bottom
        ];

        float getVectorComponent(in vec2 vector) {
            return orientation == Orientation.horizontal ? vector.x : vector.y;
        }

        const widgetSize = getVectorComponent(panel.size);
        const widgetRegionSize = widgetRegionSizes[orientation];
        const innerBoundarySize = getVectorComponent(panel.innerBoundarySize);
        const innerBoundarySizeClamped = getVectorComponent(panel.innerBoundarySizeClamped);

        with (scrollController) {
            buttonMaxOffset = widgetSize - widgetRegionSize;
            buttonMaxSize = widgetSize - widgetRegionSize;
            buttonClick = isClick;

            visibleSize = widgetSize;
            contentSize = innerBoundarySize;
            contentMaxOffset = innerBoundarySizeClamped - widgetSize;
        }
    }

    @property string state() {
        if (isClick) {
            return "Click";
        } else if (isEnter) {
            return "Enter";
        } else {
            return "Leave";
        }
    }

    void render() {
        if (!visible)
            return;

        renderer.renderChain(
            buttonRenderObjects,
            orientation,
            state,
            panel.absolutePosition + buttonOffset,
            buttonSize
        );
    }

    void onCreate(Panel panel, Theme theme, Renderer renderer) {
        app = Application.getInstance();
        auto styleData = theme.tree.data;
        this.panel = panel;
        this.renderer = renderer;
        this.styleData = styleData;

        if (orientation == Orientation.horizontal) {
            onCreateHorizontal();
        } else if (orientation == Orientation.vertical) {
            onCreateVertical();
        }
    }

    void onCreateHorizontal() {
        const string style = panel.style;

        const string[3] states = ["Leave", "Enter", "Click"];
        const string[3] parts = ["left", "center", "right"];

        const string scrollBgStyle = style ~ ".Scroll.Horizontal";
        const string scrollButtonStyle = style ~ ".Scroll.Horizontal.Button";

        // for button and bg size component is `y`
        const string bgSizeSelector = scrollBgStyle ~ ".left.3";

        createScrollController(bgSizeSelector);
        panel.renderFactory.createChain(buttonRenderObjects, scrollButtonStyle, states, parts);
    }

    void onCreateVertical() {
        const string style = panel.style;

        const string[3] states = ["Leave", "Enter", "Click"];
        const string[3] parts = ["top", "middle", "bottom"];

        const string scrollBgStyle = style ~ ".Scroll.Vertical";
        const string scrollButtonStyle = style ~ ".Scroll.Vertical.Button";

        // for button and bg size component is `x`
        const string bgSizeSelector = scrollBgStyle ~ ".middle.2";

        createScrollController(bgSizeSelector);
        panel.renderFactory.createChain(buttonRenderObjects, scrollButtonStyle, states, parts);
    }

    void createScrollController(in string bgSizeSelector) {
        const string buttonMinSizeSelector = panel.style ~ ".Scroll.buttonMinSize.0";
        scrollController = new ScrollController(orientation);
        scrollController.buttonMinSize = styleData.getNumber(buttonMinSizeSelector);
        width = styleData.getNumber(bgSizeSelector);
    }

    void createChain(in string style, in string[3] states, in string[3] parts) {
        foreach (string part; parts) {
            panel.renderFactory.createQuad(buttonRenderObjects, style, states, part);
        }
    }

    /// This method invokes when panel size is updated.
    void updateSize() {
        updateController();
        visible = scrollController.contentSize > scrollController.visibleSize;

        if (orientation == Orientation.horizontal) {
            buttonSize = scrollController.buttonSize;
            buttonOffset = vec2(
                scrollController.buttonOffset,
                panel.size.y - width
            );
        } else if (orientation == Orientation.vertical) {
            buttonSize = scrollController.buttonSize;
            buttonOffset = vec2(
                panel.size.x - width,
                scrollController.buttonOffset + panel.extraInnerOffset.top
            );
        }

        if (!visible) {
            scrollController.setOffsetInPercent(0);
            return;
        }

        scrollController.pollButton();
    }

    void progress() {
        Rect rect;

        if (orientation == Orientation.horizontal) {
            rect = Rect(
                panel.absolutePosition + buttonOffset,
                vec2(buttonSize, panel.extraInnerOffset.bottom)
            );
        } else if (orientation == Orientation.vertical) {
            rect = Rect(
                panel.absolutePosition + buttonOffset,
                vec2(panel.extraInnerOffset.right, buttonSize)
            );
        }

        isEnter = pointInRect(app.mousePos, rect);
    }
}

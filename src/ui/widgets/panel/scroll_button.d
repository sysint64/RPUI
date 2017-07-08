module ui.widgets.panel.scroll_button;

import std.typecons;

import gapi;
import rpdl;
import application;
import math.linalg;
import basic_types;

import ui.theme;
import ui.scroll;
import ui.render_objects;
import ui.renderer;

import ui.widgets.panel.widget;


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
    RPDLTree styleData;
    vec2 buttonOffset;
    float buttonSize;

    this(in Orientation orientation) {
        this.orientation = orientation;
    }

    // Update scrollController properties
    void updateController() {
        const float[Orientation] widgetRegionOffsets = [
            Orientation.horizontal: panel.innerOffset.right,
            Orientation.vertical: panel.innerOffset.bottom
        ];

        float getVectorComponent(in vec2 vector) {
            return orientation == Orientation.horizontal ? vector.x : vector.y;
        }

        const widgetSize = getVectorComponent(panel.size);
        const widgetRegionOffset = widgetRegionOffsets[orientation];
        const innerBoundarySize = getVectorComponent(panel.innerBoundarySize);
        const innerBoundarySizeClamped = getVectorComponent(panel.innerBoundarySizeClamped);

        with (scrollController) {
            buttonMaxOffset = widgetSize - widgetRegionOffset;
            buttonMaxSize = widgetSize - widgetRegionOffset;
            buttonClick = isClick;

            contentSize = innerBoundarySize + widgetRegionOffset;
            contentMaxOffset = innerBoundarySizeClamped - widgetSize;
        }
    }

    @property string state() {
        if (isClick) {
            return "Click";
        } else if (isEnter){
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
        RPDLTree styleData = theme.data;
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
        createChain(scrollButtonStyle, states, parts);
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
        createChain(scrollButtonStyle, states, parts);
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

    void onProgress() {
        Rect rect;

        if (orientation == Orientation.horizontal) {
            visible = panel.innerBoundarySize.x > panel.size.x;
            buttonSize = scrollController.buttonSize - panel.innerOffset.left;
            buttonOffset = vec2(
               scrollController.buttonOffset,
               panel.size.y - panel.innerOffset.bottom
            );
            rect = Rect(
                panel.absolutePosition + buttonOffset,
                vec2(buttonSize, panel.innerOffset.bottom)
            );
        } else if (orientation == Orientation.vertical) {
            visible = panel.innerBoundarySize.y > panel.size.y;
            buttonSize = scrollController.buttonSize - panel.innerOffset.top;
            buttonOffset = vec2(
                panel.size.x - panel.innerOffset.right,
                scrollController.buttonOffset + panel.innerOffset.top
            );
            rect = Rect(
                panel.absolutePosition + buttonOffset,
                vec2(panel.innerOffset.right, buttonSize)
            );
        }

        isEnter = pointInRect(app.mousePos, rect);
        updateController();
        scrollController.pollButton();
    }
}

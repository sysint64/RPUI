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
    float buttonMinSize = 20;

    this(in Orientation orientation) {
        this.orientation = orientation;
    }

    // Update scrollController properties
    // TODO: make the method easier
    void updateController() {
        float comp(vec2 v, in string c) {
            return c == "x" ? v.x : v.y;
        }

        const string vecComponent = orientation == Orientation.vertical ? "y" : "x";
        const float widgetSize = comp(panel.size, vecComponent);
        const float widgetRegionOffset = orientation == Orientation.vertical ?
            panel.regionOffset.bottom : panel.regionOffset.right;

        with (scrollController) {
            buttonMaxOffset = widgetSize - widgetRegionOffset;
            buttonMaxSize = widgetSize - widgetRegionOffset;
            contentSize = comp(panel.innerBoundarySize, vecComponent);
            buttonClick = isClick;
            contentMaxOffset = comp(panel.innerBoundarySizeClamped, vecComponent) -
                widgetSize + widgetRegionOffset;
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

        renderer.renderChain(buttonRenderObjects, orientation, state,
                             panel.absolutePosition + buttonOffset,
                             buttonSize);
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

        buttonMinSize = styleData.optNumber(panel.style ~ ".Scroll.buttonMinSize.0", buttonMinSize);
    }

    void onCreateHorizontal() {
        const string style = panel.style;

        const string[3] states = ["Leave", "Enter", "Click"];
        const string[3] parts = ["left", "center", "right"];

        const string scrollBgStyle = style ~ ".Scroll.Horizontal";
        const string scrollButtonStyle = style ~ ".Scroll.Horizontal.Button";

        // for button and bg size component is `y`
        const string buttonSizeSelector = scrollButtonStyle ~ ".Leave.left.3";
        const string bgSizeSelector = scrollBgStyle ~ ".left.3";

        createScrollController(buttonSizeSelector, bgSizeSelector);
        createChain(scrollButtonStyle, states, parts);
    }

    void onCreateVertical() {
        const string style = panel.style;

        const string[3] states = ["Leave", "Enter", "Click"];
        const string[3] parts = ["top", "middle", "bottom"];

        const string scrollBgStyle = style ~ ".Scroll.Vertical";
        const string scrollButtonStyle = style ~ ".Scroll.Vertical.Button";

        // for button and bg size component is `x`
        const string buttonSizeSelector = scrollButtonStyle ~ ".Leave.top.2";
        const string bgSizeSelector = scrollBgStyle ~ ".middle.2";

        createScrollController(buttonSizeSelector, bgSizeSelector);
        createChain(scrollButtonStyle, states, parts);
    }

    void createScrollController(in string buttonSizeSelector, in string bgSizeSelector) {
        scrollController = new ScrollController(orientation);
        scrollController.buttonMinSize = styleData.getNumber(buttonSizeSelector) * 2;
        width = styleData.getNumber(bgSizeSelector);
    }

    void createChain(in string style, in string[3] states, in string[3] parts) {
        foreach (string part; parts) {
            panel.renderFactory.createQuad(buttonRenderObjects, style, states, part);
        }
    }

    void onProgress() {
        visible = panel.innerBoundarySize.y > panel.size.y;
        Rect rect;

        if (orientation == Orientation.horizontal) {
            buttonOffset = vec2(scrollController.buttonOffset,
                                panel.size.y - panel.regionOffset.bottom);
            buttonSize = scrollController.buttonSize - panel.regionOffset.left;
            rect = Rect(panel.absolutePosition + buttonOffset,
                        vec2(buttonSize, panel.regionOffset.bottom));
        } else if (orientation == Orientation.vertical) {
            buttonOffset = vec2(panel.size.x - panel.regionOffset.right,
                                scrollController.buttonOffset + panel.regionOffset.top);
            buttonSize = scrollController.buttonSize - panel.regionOffset.top;
            rect = Rect(panel.absolutePosition + buttonOffset,
                        vec2(panel.regionOffset.right, buttonSize));
        }

        if (buttonSize < buttonMinSize)
            buttonSize = buttonMinSize;

        isEnter = pointInRect(app.mousePos, rect);
        updateController();
        scrollController.pollButton();
    }
}

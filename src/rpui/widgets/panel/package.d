module rpui.widgets.panel;

import std.container;
import std.algorithm.comparison;
import std.stdio;

import rpdl;

import rpui.basic_types;
import rpui.widget;
import rpui.scroll;
import rpui.input;
import rpui.view;
import rpui.cursor;
import rpui.render_objects;
import rpui.events;
import rpui.widget_events;

import rpui.widgets.panel.measure;
import rpui.widgets.panel.render;
// import rpui.widgets.panel.split;
// import rpui.widgets.panel.header;
// import rpui.widgets.panel.scroll_button;

/**
 * Panel widget is the container for other widgets with scrolling,
 * resizing, allow change placement by drag and drop.
 */
class Panel : Widget/*, FocusScrollNavigation*/ {
    enum Background {
        transparent,  /// Render without color.
        light,
        dark,
        action  /// Color for actions like OK, Cancel etc.
    }

    @field float minSize = 40;  /// Minimum size of panel.
    @field float maxSize = 999;  /// Maximum size of panel.
    @field Background background = Background.light;  /// Background color of panel.
    @field bool userCanResize = true;
    @field bool userCanHide = false;
    @field bool userCanDrag = false;

    /// If true, then panel is open and will be rendered all content else only header.
    @field bool isOpen = true;
    @field bool blackSplit = false;  /// If true, then panel split will be black.
    @field bool showSplit = true;  /// If true, render panel split else no.

    @field bool showVerticalScrollButton = true;
    @field bool showHorizontalScrollButton = true;

    @field utf32string caption = "";

    package Measure measure;
    private RenderData renderData;
    private RenderTransforms renderTransforms;

    this(in string style = "Panel") {
        super(style);
        skipFocus = true;
    }

    override void onRender() {
        render(this, view.theme, renderData, renderTransforms);
    }

    protected override void onCreate() {
        super.onCreate();
        measure = readMeasure(view.theme.tree.data, style);
        renderData = readRenderData(view.theme, style);
    }

    override void onProgress(in ProgressEvent event) {
        super.onProgress(event);

        // split.isEnter = false;

        // handleResize();
        // header.progress();

        // Update render elements position and sizes
        locator.updateRegionAlign();
        locator.updateAbsolutePosition();

        // updateInnerOffset();
        updateSize();
        updateRenderTransforms(this, &renderTransforms, &renderData, &view.theme);

        // if (!isFreezingSource() && !isFrozen()) {
        //     horizontalScrollButton.progress();
        //     verticalScrollButton.progress();
        // } else {
        //     horizontalScrollButton.isEnter = false;
        //     verticalScrollButton.isEnter = false;
        // }
    }

    override void updateSize() {
        if (isOpen) {
            updatePanelSize();

            // horizontalScrollButton.updateSize();
            // verticalScrollButton.updateSize();
        }

        // split.calculate();

        // with (horizontalScrollButton)
            // contentOffset.x = visible ? scrollController.contentOffset : 0;

        // with (verticalScrollButton)
            // contentOffset.y = visible ? scrollController.contentOffset : 0;
    }

    private void updatePanelSize() {
        if (heightType == SizeType.wrapContent) {
            size.y = innerBoundarySize.y;
        }

        if (widthType == SizeType.wrapContent) {
            size.x = innerBoundarySize.x;
        }
    }
}

module rpui.widgets.list_menu.widget;

import std.container.array;

import rpui.basic_rpdl_exts;
import rpui.events;
import rpui.input;
import rpui.math;
import rpui.primitives;
import rpui.widget;
import rpui.widgets.list_menu_item.widget;
import rpui.widgets.list_menu.renderer;
import rpui.widgets.stack_layout.stack_locator;

class ListMenu : Widget {
    @field bool transparent = false;
    @field bool checkList = false;
    @field bool isPopup = true;
    @field bool isBindDataMode = false;
    @field string listItemStyle = "ListMenuItem";

    private StackLocator stackLocator;

    package struct Measure {
        float displayDelay = 0f;
        FrameRect popupExtraPadding;
        vec2 downPopupOffset;
        vec2 rightPopupOffset;
        FrameRect extraMenuVisibleBorder;
    }

    Measure measure;

    this(in string style = "ListMenu") {
        super(style);

        this.renderer = new ListMenuRenderer();
        this.stackLocator.attach(this);
        this.stackLocator.orientation = Orientation.vertical;
        this.widthType = SizeType.value;
        this.heightType = SizeType.wrapContent;
    }

    override void onCreate() {
        super.onCreate();
        loadMeasure();
    }

    private void loadMeasure() {
        with (view.theme.tree) {
            measure.popupExtraPadding = data.getFrameRect(style ~ ".popupExtraPadding");
            measure.rightPopupOffset = data.getVec2f(style ~ ".rightPopupOffset");
            measure.downPopupOffset = data.getVec2f(style ~ ".downPopupOffset");
            measure.extraMenuVisibleBorder = data.getFrameRect(style ~ ".extraMenuVisibleBorder");
            measure.displayDelay = data.getNumber(style ~ ".displayDelay.0");
        }
    }

    override void onProgress(in ProgressEvent event) {
        super.onProgress(event);

        locator.updateAbsolutePosition();
        locator.updateLocationAlign();
        locator.updateVerticalLocationAlign();
        locator.updateRegionAlign();

        updateSize();

        if (isPopup) {
            extraInnerOffset = measure.popupExtraPadding;
        }
    }

    override void updateSize() {
        super.updateSize();

        stackLocator.updateWidgetsPosition();
        stackLocator.updateSize();
    }

    void hideAllSubMenus() {
        foreach (Widget widget; children) {
            const row = widget.associatedWidget;

            if (auto item = cast(MenuActions) row) {
                item.hideMenu();
            }
        }
    }

    // TODO(Andrey): visibility
    void hideAllSubMenusExcept(Widget menuItem) {
        foreach (Widget widget; children) {
            const row = widget.associatedWidget;

            if (row == menuItem)
                continue;

            if (auto item = cast(MenuActions) row) {
                item.hideMenu();
            }
        }
    }

    void bindData(T)(ref Array!(T) items, Widget delegate(T item) factory) {
        children.clear();

        for (int i = 0; i < items.length; ++i) {
            auto widget = factory(items[i]);
            children.addWidget(widget);
            widget.onPostCreate();
        }

        if (parent == view.rootWidget) {
            // NOTE(Andrey): reorder children
            view.moveWidgetToFront(this);
        }
    }
}

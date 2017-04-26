module ui.views.view;

import std.traits : hasUDA, getUDAs, isFunction, isType, isAggregateType;
import std.stdio;
import std.path;

import traits;
import application;

import ui.widget;
import ui.widgets.rpdl_factory;
import ui.views.attributes;
import ui.manager;
import ui.widgets.panel.widget;


class View {
    Application app;
    Manager uiManager;

    this(this T)(Manager manager, in string fileName) {
        assert(manager !is null);
        app = Application.getInstance();
        this.uiManager = manager;

        widgetFactory = new RPDLWidgetFactory(uiManager, fileName);
        widgetFactory.createWidgets();
        rootWidget = widgetFactory.rootWidget;
        assert(rootWidget !is null);

        readAttributes!T();
    }

    static createFromFile(T : View)(Manager manager, in string fileName) {
        auto app = Application.getInstance();
        const string path = buildPath(app.resourcesDirectory, "ui", "layouts", fileName);
        return new T(manager, path);
    }

    Widget findWidgetByName(in string name) {
        return rootWidget.findWidgetByName(name);
    }

private:
    RPDLWidgetFactory widgetFactory;
    Widget rootWidget;

    void readAttributes(T : View)() {
        Widget widget = findWidgetByName("closeButton");
        writeln(widget);
        // foreach (symbol; getSymbolsByUDA!(T, OnClickListener)) {
        //     assert(isFunction!symbol);

        //     foreach (uda; getUDAs!(symbol, OnClickListener)) {
        //         writeln(uda.name);
        //         Widget widget = findWidgetByName(uda.name);
        //         assert(widget !is null);
        //     }
        // }
    }
}

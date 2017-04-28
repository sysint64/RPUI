module ui.views.view;

import std.traits : hasUDA, getUDAs, isFunction, isType, isAggregateType;
import std.stdio;
import std.path;
import std.meta;

import traits;
import application;

import ui.widget;
import ui.widgets.rpdl_factory;
import ui.views.attributes;
import ui.manager;
import ui.widgets.panel.widget;

import editor.mapeditor : MyView;


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

    void readEventAttribute(T : View, string eventName)(T view) {
        mixin("alias event = " ~ eventName ~ ";");

        foreach (symbolName; getSymbolsNamesByUDA!(T, event)) {
            mixin("alias symbol = T." ~ symbolName ~ ";");
            assert(isFunction!symbol);

            foreach (uda; getUDAs!(symbol, event)) {
                Widget widget = findWidgetByName(uda.widgetName);
                assert(widget !is null);

                enum widgetEventName = "on" ~ eventName[2..$];
                mixin("widget." ~ widgetEventName ~ " = &view." ~ symbolName ~ ";");
                writeln("widget." ~ widgetEventName ~ " = &view." ~ symbolName ~ ";");
            }
        }
    }

    void readEventsAttributes(T : View)(T view) {
        enum events = AliasSeq!(
            "OnClickListener",
            "OnDblClickistener",
            "OnFocusListener",
            "OnBlurListener",
            "OnKeyPressedListener",
            "OnKeyReleasedListener",
            "OnTextEnteredListener",
            "OnMouseMoveListener",
            "OnMouseEnterListener",
            "OnMouseLeaveListener",
            "OnMouseDownListener",
            "OnMouseUpListener"
        );

        foreach (eventName; events) {
            mixin("alias event = " ~ eventName ~ ";");
            readEventAttribute!(T, eventName)(view);
        }
    }

    void readAttributes(T : View)() {
        T view = cast(MyView) this;
        readEventsAttributes(view);
    }
}

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

    void readAccessorsAttributes(T : View)(T view) {
        foreach (symbolName; getSymbolsNamesByUDA!(T, ViewWidget)) {
            mixin("alias symbol = T." ~ symbolName ~ ";");

            foreach (uda; getUDAs!(symbol, ViewWidget)) {
                // Get widget name from attribute or set as symbolName
                // if empty or if it is struct
                static if (isType!uda) {
                    enum widgetName = symbolName;
                } else {
                    static if (uda.widgetName == "") {
                        enum widgetName = symbolName;
                    } else {
                        enum widgetName = uda.widgetName;
                    }
                }

                Widget widget = findWidgetByName(widgetName);
                assert(widget !is null);

                mixin("alias WidgetType = typeof(view." ~ symbolName ~ ");");
                mixin("view." ~ symbolName ~ " = cast(WidgetType) widget;");
                writeln("view." ~ symbolName ~ " = cast(WidgetType) widget;");
            }
        }
    }

    void readAttributes(T : View)() {
        T view = cast(MyView) this;
        readEventsAttributes(view);
        readAccessorsAttributes(view);
    }
}

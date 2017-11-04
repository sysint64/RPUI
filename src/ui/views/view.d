module ui.views.view;

import std.traits;
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
import ui.shortcuts;

import editor.mapeditor : MyView;


class View {
    Application app;
    Manager uiManager;
    Shortcuts shortcuts;

    @Shortcut("General.focusNext")
    void focusNext() {
        this.uiManager.focusNext();
    }

    @Shortcut("General.focusPrev")
    void focusPrev() {
        this.uiManager.focusPrev();
    }

    this(this T)(Manager manager, in string layoutFileName, in string shortcutsFileName) {
        assert(manager !is null);
        app = Application.getInstance();
        this.uiManager = manager;

        widgetFactory = new RPDLWidgetFactory(uiManager, layoutFileName);
        widgetFactory.createWidgets();
        rootWidget = widgetFactory.rootWidget;
        assert(rootWidget !is null);

        shortcuts = Shortcuts.createFromFile(shortcutsFileName);
        readAttributes!T();
    }

    static createFromFile(T : View)(Manager manager, in string fileName) {
        auto app = Application.getInstance();
        const string layoutPath = buildPath(app.resourcesDirectory, "ui", "layouts", fileName);
        const string shortcutsPath = buildPath(app.resourcesDirectory, "ui", "shortcuts", fileName);
        return new T(manager, layoutPath, shortcutsPath);
    }

    static createFromFile(T : View)(Manager manager, in string layoutFileName,
                                    in string shortcutsFilename)
    {
        auto app = Application.getInstance();
        const string layoutPath = buildPath(app.resourcesDirectory, "ui", "layouts",
                                            layoutFileName);
        const string shortcutsPath = buildPath(app.resourcesDirectory, "ui", "shortcuts",
                                               shortcutsFilename);
        return new T(manager, layoutPath, shortcutsPath);
    }

    Widget findWidgetByName(in string name) {
        return rootWidget.findWidgetByName(name);
    }

private:
    RPDLWidgetFactory widgetFactory;
    Widget rootWidget;

    // Read event listener attributes and assign this listener to
    // widget with name uda.widgetName, where uda is attribute
    void readEventAttribute(T : View, string eventName)(T view) {
        mixin("alias event = " ~ eventName ~ ";");

        foreach (symbolName; getSymbolsNamesByUDA!(T, event)) {
            mixin("alias symbol = T." ~ symbolName ~ ";");
            assert(isFunction!symbol);

            foreach (uda; getUDAs!(symbol, event)) {
                Widget widget = findWidgetByName(uda.widgetName);
                assert(widget !is null, widget.name);

                enum widgetEventName = "on" ~ eventName[2..$];
                mixin("widget." ~ widgetEventName ~ " = &view." ~ symbolName ~ ";");
            }
        }
    }

    void readEventsAttributes(T : View)(T view) {
        enum events = AliasSeq!(
            "OnClickListener",
            "OnDblClickListener",
            "OnFocusListener",
            "OnBlurListener",
            "OnKeyPressedListener",
            "OnKeyReleasedListener",
            "OnTextEnteredListener",
            "OnMouseMoveListener",
            "OnMouseWheelListener",
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

    // Get widget name from attribute or set as symbolName
    // if empty or if it is struct
    static string getNameFromAttribute(alias uda)(in string symbolName) {
        static if (isType!uda) {
            return symbolName;
        } else {
            static if (uda.widgetName == "") {
                return symbolName;
            } else {
                return uda.widgetName;
            }
        }
    }

    // Reading ViewWidget attributes to extract widget by name to variable
    void readViewWidgetAttributes(T : View)(T view) {
        foreach (symbolName; getSymbolsNamesByUDA!(T, ViewWidget)) {
            mixin("alias symbol = T." ~ symbolName ~ ";");

            foreach (uda; getUDAs!(symbol, ViewWidget)) {
                enum widgetName = getNameFromAttribute!uda(symbolName);

                Widget widget = findWidgetByName(widgetName);
                assert(widget !is null, widgetName ~ " not found");

                mixin("alias WidgetType = typeof(view." ~ symbolName ~ ");");
                mixin("view." ~ symbolName ~ " = cast(WidgetType) widget;");
            }
        }
    }

    // Reading GroupViewWidgets attributes to extract widget children by parent
    // widget name to variable
    void readGroupViewWidgets(T : View)(T view) {
        foreach (symbolName; getSymbolsNamesByUDA!(T, GroupViewWidgets)) {
            mixin("alias symbol = T." ~ symbolName ~ ";");

            foreach (uda; getUDAs!(symbol, GroupViewWidgets)) {
                enum parentWidgetName = getNameFromAttribute!uda(symbolName);

                Widget parentWidget = findWidgetByName(parentWidgetName);
                assert(parentWidget !is null);

                mixin("alias WidgetType = ForeachType!(typeof(view." ~ symbolName ~ "));");
                mixin("alias symbolType = typeof(view." ~ symbolName ~ ");");

                uint staticArrayIndex = 0;

                foreach (Widget childWidget; parentWidget.children) {
                    // Select correct widget - if associatedWidget is null then get
                    // child widget. For example row in StackLayout has one single widget
                    // this widget will be associated because of this widget is our
                    // content and row is just wrapper
                    Widget targetWidget = childWidget.associatedWidget;

                    if (targetWidget is null)
                        targetWidget = childWidget;

                    auto typedTargetWidget = cast(WidgetType) targetWidget;
                    immutable string t = "view." ~ symbolName ~ " ~= typedTargetWidget;";

                    static if (is(StaticArrayTypeOf!symbolType)) {
                        mixin("view." ~ symbolName ~ "[staticArrayIndex] = typedTargetWidget;");
                    } else {
                        mixin("view." ~ symbolName ~ " ~= typedTargetWidget;");
                    }

                    ++staticArrayIndex;
                }
            }
        }
    }

    void readShortcutsAttributes(T : View)(T view) {
        foreach (symbolName; getSymbolsNamesByUDA!(T, Shortcut)) {
            mixin("alias symbol = T." ~ symbolName ~ ";");

            foreach (uda; getUDAs!(symbol, Shortcut)) {
                enum shortcutPath = uda.shortcutPath;
                shortcuts.attach(shortcutPath, &mixin("view." ~ symbolName));
            }
        }
    }

    void readAttributes(T : View)() {
        T view = cast(T) this;
        readEventsAttributes(view);
        readViewWidgetAttributes(view);
        readGroupViewWidgets(view);
        readShortcutsAttributes(view);
    }
}

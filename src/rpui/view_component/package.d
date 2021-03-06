module rpui.view_component;

public import rpui.view_component.attributes;

import core.memory;

import std.meta;
import std.traits;
import std.path;

import rpui.events;
import rpui.widget_events;
import rpui.shortcuts : Shortcuts;
import rpui.view;
import rpui.widget;
import rpui.traits;
import rpui.paths;
import rpui.rpdl_widget_factory;
import rpui.events_observer;

/**
 * ViewComponent is a container for widgets with additional attributes processing
 * such as `rpui.view.attributes.accessors` for more convinient way to
 * access widgets, attach shortcuts to view methods and so on.
 */
abstract class ViewComponent {
    private View view;
    private Widget rootWidget;
    RpdlWidgetFactory widgetFactory;
    private Subscriber shortcutsSubscriber;

    final View getView() {
        return view;
    }

    @shortcut("General.focusNext")
    final void focusNext() {
        view.focusNext();
    }

    @shortcut("General.focusPrev")
    final void focusPrev() {
        view.focusPrev();
    }

    @shortcut("General.copy")
    final void copy() {
        view.events.notify(CopyCommand());
    }

    @shortcut("General.paste")
    final void paste() {
        view.events.notify(PasteCommand());
    }

    @shortcut("General.cut")
    final void cut() {
        view.events.notify(CutCommand());
    }

    @shortcut("General.unselect")
    final void unselect() {
        view.events.notify(UnselectCommand());
    }

    @shortcut("General.selectAll")
    final void selectAll() {
        view.events.notify(SelectAllCommand());
    }

    void onCreate() {
    }

    void onDestroy() {
    }

    void onProgress(in ProgressEvent event) {
    }

    /**
     * Create viewComponent with `view` from `layoutFileName` and load shortcuts
     * from `shortcutsFileName`.
     */
    this(this T)(View view, in string layoutFileName, in string shortcutsFileName) {
        assert(view !is null);
        this.view = view;

        auto shortcuts = Shortcuts.createFromFile(shortcutsFileName);
        view.shortcuts.merge(shortcuts);

        widgetFactory = new RpdlWidgetFactory(view, layoutFileName);
        widgetFactory.createWidgets();
        rootWidget = widgetFactory.rootWidget;
        assert(rootWidget !is null);
        readAttributes!T();

        shortcutsSubscriber = view.events.subscribe!KeyReleasedEvent(
            event => shortcuts.onKeyReleased(event.key)
        );
    }

    this(this T)(View view, Widget rootWidget) {
        assert(view !is null);
        assert(rootWidget !is null);

        this.view = view;
        this.rootWidget = rootWidget;
        readAttributes!T();
    }

    ~this() {
        view.events.unsubscribe(shortcutsSubscriber);
        onDestroy();
    }

    /**
     * Create new view instance from file placed in $(I res/ui/layouts).
     * Instance will be created of `T` type.
     */
    static createFromFile(T : ViewComponent)(View view, in string fileName) {
        const paths = createPathes();
        const layoutPath = buildPath(paths.resources, "ui", "layouts", fileName);
        const shortcutsPath = buildPath(paths.resources, "ui", "shortcuts", "general.rdl");
        auto component = new T(view, layoutPath, shortcutsPath);
        component.onCreate();
        return component;
    }

    /**
     * Create new view instance from file placed in $(I res/ui/layouts).
     * Instance will be created of `T` type.
     */
    static createFromFileWithShortcuts(T : ViewComponent)(View view, in string fileName, in string shortcuts = "") {
        const paths = createPathes();
        const layoutPath = buildPath(paths.resources, "ui", "layouts", fileName);
        const shortcutsPath = buildPath(paths.resources, "ui", "shortcuts", shortcuts == "" ? fileName : shortcuts);
        auto component = new T(view, layoutPath, shortcutsPath);
        component.onCreate();
        return component;
    }

    /**
     * Create new view instance from file placed in $(I res/ui/layouts) with custom shorcuts
     * `shortcutsFilename`. Instance will be created of `T` type.
     */
    static createFromFile(T : ViewComponent)(View view, in string layoutFileName,
                                             in string shortcutsFilename)
    {
        const paths = createPathes();
        const layoutPath = buildPath(paths.resources, "ui", "layouts", layoutFileName);
        const shortcutsPath = buildPath(paths.resources, "ui", "shortcuts", shortcutsFilename);
        auto component = new T(view, layoutPath, shortcutsPath);
        component.onCreate();
        return component;
    }

    private void readAttributes(T : ViewComponent)() {
        T viewComponent = cast(T) this;
        readEventsAttributes(viewComponent);
        readBindWidgetAttributes(viewComponent);
        readBindGroupWidgets(viewComponent);
        readShortcutsAttributes(viewComponent);
    }

    private void readEventsAttributes(T : ViewComponent)(T viewComponent) {
        enum events = AliasSeq!(
            "onClick",
            "onDblClick",
            "onFocus",
            "onBlur",
            "onMouseWheel",
            "onKeyReleased",
            "onTextEntered",
            "onMouseMove",
            "onMouseWheel",
            "onMouseEnter",
            "onMouseLeave",
            "onMouseDown",
            "onMouseUp"
        );

        static foreach (eventName; events) {
            readEventAttribute!(T, eventName)(viewComponent);
        }
    }

    /**
     * Read event listener attributes and assign this listener to
     * widget with name uda.widgetName, where uda is attribute
     */
    private void readEventAttribute(T : ViewComponent, string eventName)(T viewComponent) {
        mixin("alias event = " ~ eventName ~ "Listener;");

        foreach (symbolName; getSymbolsNamesByUDA!(T, event)) {
            mixin("alias symbol = T." ~ symbolName ~ ";");
            assert(isFunction!symbol);

            foreach (uda; getUDAs!(symbol, event)) {
                Widget widget = findWidgetByName!(uda.widgetName);
                assert(widget !is null, "Widget hasn't found: " ~ uda.widgetName);

                enum widgetEventName = eventName[2..$];

                // widget.events.subscribe!(clickEvent)(&viewComponent.onOkButtonClick);
                mixin("widget.events.subscribe!(" ~ widgetEventName ~ "Event)(&viewComponent." ~ symbolName ~ ");");
            }
        }
    }

    /// Reading ViewWidget attributes to extract widget by name to variable
    private void readBindWidgetAttributes(T : ViewComponent)(T viewComponent) {
        foreach (symbolName; getSymbolsNamesByUDA!(T, bindWidget)) {
            mixin("alias symbol = T." ~ symbolName ~ ";");

            foreach (uda; getUDAs!(symbol, bindWidget)) {
                enum widgetName = getNameFromAttribute!uda(symbolName);

                Widget widget = findWidgetByName!(widgetName);
                assert(widget !is null, widgetName ~ " not found");

                // alias WidgetType = typeof(view.cancelButton);
                // view.cancelButton = cast(WidgetType) widget;
                mixin("alias WidgetType = typeof(viewComponent." ~ symbolName ~ ");");
                mixin("viewComponent." ~ symbolName ~ " = cast(WidgetType) widget;");
            }
        }
    }

    /// Find widget in relative view root widget.
    Widget findWidgetByName(alias name)() {
        assert(rootWidget !is null);

        if (rootWidget.name == name) {
            return rootWidget;
        } else {
            return rootWidget.resolver.findWidgetByName(name);
        }
    }

    /**
     * Get widget name from attribute or set as symbolName
     * if empty or if it is struct
     */
    private static string getNameFromAttribute(alias uda)(in string symbolName) {
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

    /**
     * Reading GroupViewWidgets attributes to extract widget children by parent
     * widget name to variable
     */
    private void readBindGroupWidgets(T : ViewComponent)(T viewComponent) {
        foreach (symbolName; getSymbolsNamesByUDA!(T, bindGroupWidgets)) {
            mixin("alias symbol = T." ~ symbolName ~ ";");

            foreach (uda; getUDAs!(symbol, bindGroupWidgets)) {
                enum parentWidgetName = getNameFromAttribute!uda(symbolName);

                Widget parentWidget = findWidgetByName!(parentWidgetName);
                assert(parentWidget !is null);

                // alias WidgetType = ForeachType!(typeof(viewComponent.buttons));
                // alias symbolType = typeof(viewComponent.buttons);
                mixin("alias WidgetType = ForeachType!(typeof(viewComponent." ~ symbolName ~ "));");
                mixin("alias symbolType = typeof(viewComponent." ~ symbolName ~ ");");

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
                    immutable t = "viewComponent." ~ symbolName ~ " ~= typedTargetWidget;";

                    static if (is(StaticArrayTypeOf!symbolType)) {
                        // viewComponent.buttons[staticArrayIndex] = typedTargetWidget;
                        mixin("viewComponent." ~ symbolName ~ "[staticArrayIndex] = typedTargetWidget;");
                    } else {
                        // viewComponent.buttons ~= typedTargetWidget;
                        mixin("viewComponent." ~ symbolName ~ " ~= typedTargetWidget;");
                    }

                    ++staticArrayIndex;
                }
            }
        }
    }

    private void readShortcutsAttributes(T : ViewComponent)(T viewComponent) {
        foreach (symbolName; getSymbolsNamesByUDA!(T, shortcut)) {
            // alias symbol = T.shortcutAction;
            mixin("alias symbol = T." ~ symbolName ~ ";");

            foreach (uda; getUDAs!(symbol, shortcut)) {
                if (uda.retrieve) {
                    // shortcuts.attachByPath(shortcutPath, &viewComponent.shortcutAction);
                    view.shortcuts.attachByPath(uda.value, &mixin("viewComponent." ~ symbolName));
                } else {
                    // shortcuts.attach(shortcutPath, &viewComponent.shortcutAction);
                    view.shortcuts.attach(uda.value, &mixin("viewComponent." ~ symbolName));
                }
            }
        }
    }
}

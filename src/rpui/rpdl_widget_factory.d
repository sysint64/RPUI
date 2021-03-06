module rpui.rpdl_widget_factory;

import std.path;
import std.meta;
import std.traits : hasUDA, getUDAs, isFunction, ParameterDefaults, Unqual;
import std.container.array;

import rpdl;
import rpdl.node;
import rpui.basic_rpdl_exts;
import rpui.gapi_rpdl_exts;

import gapi.texture;

import rpui.math;
import rpui.primitives;
import rpui.traits;
import rpui.widget;
import rpui.view;

import rpui.widgets.button.widget;
import rpui.widgets.panel.widget;
import rpui.widgets.stack_layout.widget;
import rpui.widgets.label.widget;
import rpui.widgets.multiline_label.widget;
import rpui.widgets.checkbox.widget;
import rpui.widgets.text_input.widget;
import rpui.widgets.list_menu.widget;
import rpui.widgets.list_menu_item.widget;
import rpui.widgets.list_menu_items_divider.widget;
import rpui.widgets.drop_list_menu.widget;
import rpui.widgets.tab_layout.widget;
import rpui.widgets.tab_button.widget;
import rpui.widgets.chain_layout.widget;
import rpui.widgets.check_button.widget;
import rpui.widgets.switch_button.widget;
import rpui.widgets.dialog.widget;
import rpui.widgets.tree_list.widget;
import rpui.widgets.tree_list_node.widget;
import rpui.widgets.canvas.widget;
import rpui.widgets.main_menu.widget;
import rpui.widgets.main_menu_item.widget;
import rpui.widgets.toolbar.widget;
import rpui.widgets.toolbar_tab_layout.widget;
import rpui.widgets.toolbar_tab_button.widget;
import rpui.widgets.toolbar_items_layout.widget;
import rpui.widgets.toolbar_item.widget;
import rpui.widgets.toolbar_items_divider.widget;

/// Factory for construction view from rpdl layout data.
final class RpdlWidgetFactory {
    /// Root view widget - container for other widgets.
    @property Widget rootWidget() { return rootWidget_; }
    private Widget rootWidget_;

    private RpdlTree layoutData;
    private View view;

    this(View view, in string fileName) {
        layoutData = new RpdlTree(dirName(fileName));
        layoutData.load(baseName(fileName), RpdlTree.FileType.text);
        debug layoutData.save(baseName(fileName ~ ".bin"), RpdlTree.FileType.bin);
        this.view = view;
    }

    /**
     * This is a main method of factory - it will create and insert widgets
     * by reading the children of `widgetNode`, if `widgetNode` is null
     * then reading will be from layout root node.
     */
    void createWidgets(Node widgetNode = null) {
        if (widgetNode is null) {
            widgetNode = layoutData.root;
        }

        foreach (Node childNode; widgetNode.children) {
            if (auto objectNode = cast(ObjectNode) childNode) {
                auto widget = createWidgetFromNode(objectNode);
                readVisibleRules(widget, objectNode);
                widget.onPostCreate();
            } else {
                throw new Error("Failed to create widget");
            }
        }
    }

    /// Create widget depends of `widgetNode.name` and insert to `parentWidget`.
    Widget createWidgetFromNode(ObjectNode widgetNode, Widget parentWidget = null) {
        switch (widgetNode.name) {
            case "Button":
                return createWidget!Button(widgetNode, parentWidget);

            case "Panel":
                return createWidget!Panel(widgetNode, parentWidget);

            case "StackLayout":
                return createWidget!StackLayout(widgetNode, parentWidget);

            case "Label":
                return createWidget!Label(widgetNode, parentWidget);

            case "MultilineLabel":
                return createWidget!MultilineLabel(widgetNode, parentWidget);

            case "Checkbox":
                return createWidget!Checkbox(widgetNode, parentWidget);

            case "TextInput":
                return createWidget!TextInput(widgetNode, parentWidget);

            case "ListMenu":
                return createWidget!ListMenu(widgetNode, parentWidget);

            case "ListMenuItem":
                return createWidget!ListMenuItem(widgetNode, parentWidget);

            case "DropListMenu":
                return createWidget!DropListMenu(widgetNode, parentWidget);

            case "TabLayout":
                return createWidget!TabLayout(widgetNode, parentWidget);

            case "TabButton":
                return createWidget!TabButton(widgetNode, parentWidget);

            case "ChainLayout":
                return createWidget!ChainLayout(widgetNode, parentWidget);

            case "CheckButton":
                return createWidget!CheckButton(widgetNode, parentWidget);

            case "SwitchButton":
                return createWidget!SwitchButton(widgetNode, parentWidget);

            case "TreeListNode":
                return createWidget!TreeListNode(widgetNode, parentWidget);

            case "TreeList":
                return createWidget!TreeList(widgetNode, parentWidget);

            case "Dialog":
                return createWidget!Dialog(widgetNode, parentWidget);

            case "Canvas":
                return createWidget!Canvas(widgetNode, parentWidget);

            case "MainMenu":
                return createWidget!MainMenu(widgetNode, parentWidget);

            case "MainMenuItem":
                return createWidget!MainMenuItem(widgetNode, parentWidget);

            case "Toolbar":
                return createWidget!Toolbar(widgetNode, parentWidget);

            case "ToolbarTabLayout":
                return createWidget!ToolbarTabLayout(widgetNode, parentWidget);

            case "ToolbarTabButton":
                return createWidget!ToolbarTabButton(widgetNode, parentWidget);

            case "ToolbarItemsLayout":
                return createWidget!ToolbarItemsLayout(widgetNode, parentWidget);

            case "ToolbarItem":
                return createWidget!ToolbarItem(widgetNode, parentWidget);

            case "ToolbarItemsDivider":
                return createWidget!ToolbarItemsDivider(widgetNode, parentWidget);

            case "ListMenuItemsDivider":
                return createWidget!ListMenuItemsDivider(widgetNode, parentWidget);

            default:
                throw new Error("Unspecified widget type " ~ widgetNode.name);
        }
    }

    /**
     * Create widget from `widgetNode` data and insert it to `parentWidget`.
     * If `parentWidget` is null then insert to `uiManager` root view widget.
     */
    Widget createWidget(T : Widget)(ObjectNode widgetNode, Widget parentWidget = null) {
        T widget = new T();
        readFields!T(widget, widgetNode);

        if (parentWidget !is null) {
            parentWidget.children.addWidget(widget);
        } else {
            rootWidget_ = view.rootWidget;
            view.addWidget(widget);
        }

        // Create children widgets
        foreach (Node childNode; widgetNode.children) {
            if (auto objectNode = cast(ObjectNode) childNode) {
                Widget newWidget = createWidgetFromNode(objectNode, widget);
                readVisibleRules(newWidget, objectNode);
                newWidget.onPostCreate();
            }
        }

        return widget;
    }

    // Tell the system how to interprete types of fields in widgets
    // and how to extract them
    // first argumen is name of type
    // second is accessor in RpdlTree
    // third is selector - additional path to find value
    private enum name = 0;
    private enum accessor = 1;
    private enum selector = 2;

    private enum typesMap = AliasSeq!(
        ["bool", "optBoolean", ".0"],
        ["int", "optInteger", ".0"],
        ["float", "optNumber", ".0"],
        ["string", "optString", ".0"],
        ["dstring", "optUTF32String", ".0"],

        ["vec2", "optVec2f", ""],
        ["vec3", "optVec3f", ""],
        ["vec4", "optVec4f", ""],
        ["vec2i", "optVec2i", ""],
        ["vec3i", "optVec3i", ""],
        ["vec4i", "optVec4i", ""],
        ["vec2ui", "optVec2ui", ""],
        ["vec3ui", "optVec3ui", ""],
        ["vec4ui", "optVec4ui", ""],

        ["Texture2DCoords", "optTexCoord", ""],
        ["Rect", "optRect", ""],
        ["FrameRect", "optFrameRect", ""],
        ["IntRect", "optIntRect", ""],
    );

    /**
     * Finds all fields in widget with @`rpui.widget.Widget.field` attribute
     * and fill widget members with values from rpdl file.
     */
    void readFields(T : Widget)(T widget, ObjectNode widgetNode) {
        foreach (symbolName; getSymbolsNamesByUDA!(T, Widget.field)) {
            auto defaultValue = mixin("widget." ~ symbolName);
            alias SymbolType = typeof(defaultValue);

            static if (is(SymbolType == Array!CT, CT)) {
                auto array = widgetNode.getNode(symbolName);

                if (array is null)
                    continue;

                foreach (node; array.children) {
                    readArrayField!(T, CT, symbolName)(widget, widgetNode, node.name);
                }
            }
            else {
                readField!(T, SymbolType, symbolName)(widget, widgetNode, defaultValue);
            }
        }
    }

    private void readField(T : Widget, SymbolType, string symbolName)
        (T widget, Node widgetNode, SymbolType defaultValue = SymbolType.init)
    {
        bool foundType = false;

        foreach (type; typesMap) {
            mixin("alias RawType = " ~ type[name] ~ ";");

            static if (is(SymbolType == RawType)) {
                foundType = true;
                const fullSymbolPath = symbolName ~ type[selector];
                enum call = "widgetNode." ~ type[accessor] ~ "(fullSymbolPath, defaultValue)";
                const value = mixin(call);

                static if (type[name] == "dstring") {
                    assert(view.resources.strings !is null);
                    mixin("widget." ~ symbolName ~ " = view.resources.strings.parseString(value);");
                } else {
                    mixin("widget." ~ symbolName ~ " = value;");
                }

                break;
            }
        }

        if (!foundType) {
            static if (is(SymbolType == enum)) {
                const value = widgetNode.optEnum!(SymbolType)(symbolName ~ ".0", defaultValue);
                mixin("widget." ~ symbolName ~ " = value;");
            } else

            // Check if unsupported type is array
            static if (is(SymbolType == CT[], CT)) {
                auto array = widgetNode.getNode(symbolName);

                if (array is null)
                    return;

                foreach (node; array.children) {
                    readArrayField!(T, Unqual!CT, symbolName)(widget, widgetNode, node.name);
                }
            } else {
                assert(false, "type " ~ SymbolType.stringof ~ " doesn't allow");
            }
        }
    }

    private void readArrayField(T : Widget, SymbolType, string symbolName)
        (T widget, Node widgetNode, string nodeName)
    {
        const defaultValue = SymbolType.init;
        bool foundType = false;

        foreach (type; typesMap) {
            mixin("alias RawType = " ~ type[name] ~ ";");

            static if (is(SymbolType == RawType)) {
                foundType = true;
                const fullSymbolPath = symbolName ~ "." ~ nodeName;// ~ type[selector];
                enum call = "widgetNode." ~ type[accessor] ~ "(fullSymbolPath, defaultValue)";
                const value = mixin(call);

                // assign value to widget field
                static if (type[name] == "dstring") {
                    mixin("widget." ~ symbolName ~ " ~= uiManager.stringsRes.parseString(value);");
                } else {
                    mixin("widget." ~ symbolName ~ " ~= value;");
                }

                break;
            }
        }

        assert(foundType, "type " ~ SymbolType.stringof ~ " doesn't allow");
    }

    private void readVisibleRules(Widget widget, ObjectNode widgetNode) {
        const rule = widgetNode.optString("tabVisibleRule.0", null);

        if (rule !is null ) {
            auto dependWidget = cast(TabButton) rootWidget.resolver.findWidgetByName(rule);

            if (dependWidget !is null) {
                widget.visibleRules.insert(() => dependWidget.checked);
            }
        }
    }
}

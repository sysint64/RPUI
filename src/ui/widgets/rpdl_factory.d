module ui.widgets.rpdl_factory;

import traits;

import rpdl;
import rpdl.node;

import std.path;
import std.stdio;
import std.typecons: tuple;
import std.meta;
import std.traits : hasUDA, getUDAs, isFunction, ParameterDefaults;

import math.linalg;
import basic_types;
import ui.widget;
import ui.views.attributes;
import ui.manager;

import gapi.texture;

import ui.cursor;
import ui.widgets.panel.widget;
import ui.widgets.button;
import ui.widgets.stack_layout;


class RPDLWidgetFactory {
    @property Widget rootWidget() { return p_rootWidget; }
    @disable @property void rootWidget(Widget val) {};

    this(Manager uiManager, in string fileName) {
        layoutData = new RPDLTree(dirName(fileName));
        layoutData.load(baseName(fileName), RPDLTree.IOType.text);
        debug layoutData.save(baseName(fileName ~ ".bin"), RPDLTree.IOType.bin);
        this.uiManager = uiManager;
    }

    this(Manager uiManager) {
        this.uiManager = uiManager;
    }

    static RPDLWidgetFactory createStatic(string fileName)(Manager uiManager) {
        RPDLWidgetFactory factory = RPDLWidgetFactory(uiManager);
        layoutData = new RPDLTree(dirName(fileName));
        layoutData.staticLoad!(baseName(fileName))();
    }

    Widget createWidgetFromNode(ObjectNode widgetNode, Widget parentWidget = null) {
        switch (widgetNode.name) {
            case "StackLayout":
                return createWidget!StackLayout(widgetNode, parentWidget);

            case "Panel":
                return createWidget!Panel(widgetNode, parentWidget);

            case "Button":
                return createWidget!Button(widgetNode, parentWidget);

            default:
                return null;
        }
    }

    void createWidgets(Node widgetNode = null) {
        if (widgetNode is null)
            widgetNode = layoutData.root;

        foreach (Node childNode; widgetNode.children) {
            if (auto objectNode = cast(ObjectNode) childNode) {
                createWidgetFromNode(objectNode);
            } else {
                // TODO: throw an exception
            }
        }
    }

    Widget createWidget(T : Widget)(ObjectNode widgetNode, Widget parentWidget = null) {
        T widget = new T();
        readFields!T(widget, widgetNode);

        if (parentWidget !is null) {
            parentWidget.addWidget(widget);
        } else {
            p_rootWidget = uiManager.rootWidget;
            uiManager.addWidget(widget);
        }

        // Create children widgets
        foreach (Node childNode; widgetNode.children) {
            if (auto objectNode = cast(ObjectNode) childNode) {
                createWidgetFromNode(objectNode, widget);
            }
        }

        return widget;
    }

    // Find all fields in widget with @Field attribute and fill widget members
    // with values from rpdl file
    void readFields(T : Widget)(T widget, ObjectNode widgetNode) {
        foreach (symbolName; getSymbolsNamesByUDA!(T, Widget.Field)) {
            auto symbol = mixin("widget." ~ symbolName);
            alias symbolType = typeof(symbol);

            // Tell the system how to interprete types of fields in widgets
            // and how to extract them
            // first argumen is name of type
            // second is accessor in RPDLTree
            // third is selector - additional path to find value
            enum name = 0;
            enum accessor = 1;
            enum selector = 2;

            enum typesMap = AliasSeq!(
                ["bool", "optBoolean", ".0"],
                ["int", "optInteger", ".0"],
                ["float", "optNumber", ".0"],
                ["string", "optString", ".0"],
                ["dstring", "optUTFString", ".0"],

                ["vec2", "optVec2f", ""],
                ["vec3", "optVec3f", ""],
                ["vec4", "optVec4f", ""],
                ["vec2i", "optVec2i", ""],
                ["vec3i", "optVec3i", ""],
                ["vec4i", "optVec4i", ""],
                ["vec2ui", "optVec2ui", ""],
                ["vec3ui", "optVec3ui", ""],
                ["vec4ui", "optVec4ui", ""],

                ["Texture.Coord", "optTexCoord", ""],
                ["Align", "optAlign", ".0"],
                ["VerticalAlign", "optVerticalAlign", ".0"],
                ["Orientation", "optOrientation", ".0"],
                ["RegionAlign", "optRegionAlign", ".0"],
                ["Rect", "optRect", ""],
                ["FrameRect", "optFrameRect", ""],
                ["IntRect", "optIntRect", ""],

                ["Cursor.Icon", "optCursorIcon", ".0"],
                ["Panel.Background", "optPanelBackground", ".0"],
            );

            foreach (type; typesMap) {
                mixin("alias rawType = " ~ type[name] ~ ";");

                static if (is(symbolType == rawType)) {
                    auto fullSymbolPath = symbolName ~ type[selector];
                    enum call = "widgetNode." ~ type[accessor] ~ "(fullSymbolPath, symbol)";
                    auto value = mixin(call);

                    // assign value to widget field
                    mixin("widget." ~ symbolName ~ " = value;");
                }
            }
        }
    }

private:
    RPDLTree layoutData;
    Manager uiManager;
    Widget p_rootWidget;
}

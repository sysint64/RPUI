module ui.widgets.rpdl_factory;

import std.path;

import rpdl;
import rpdl.node;

import std.stdio;
import std.typecons: tuple;
import std.meta;
import std.traits : hasUDA, getUDAs, isFunction, ParameterDefaults;

import basic_types;
import ui.widget;
import ui.views.attributes;
import ui.manager;

import ui.widgets.panel.widget;
import ui.widgets.button;

import ui.views.view : getSymbolsNamesByUDA, getSymbolsByUDA; // TODO: rm, workaround


class RPDLWidgetFactory {
    this(in string fileName) {
        layoutData = new RPDLTree(dirName(fileName));
        layoutData.load(baseName(fileName));
    }

    void createWidgets(Manager uiManager) {
        this.uiManager = uiManager;
        createWidgets();
    }

    Widget createWidgetFromNode(ObjectNode widgetNode, Widget parentWidget = null) {
        switch (widgetNode.name) {
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

            const string symbolTypeName = symbolType.stringof;
            const string symbolPath = widgetNode.path ~ "." ~ symbolName;

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

                ["Vector!(float, 2)", "optVec2f", ""],
                ["Vector!(float, 3)", "optVec3f", ""],
                ["Vector!(float, 4)", "optVec4f", ""],
                ["Vector!(int, 2)", "optVec2i", ""],
                ["Vector!(int, 3)", "optVec3i", ""],
                ["Vector!(int, 4)", "optVec4i", ""],
                ["Vector!(uint, 2)", "optVec2ui", ""],
                ["Vector!(uint, 3)", "optVec3ui", ""],
                ["Vector!(uint, 4)", "optVec4ui", ""],

                ["Coord", "optTexCoord", ""],
                ["Align", "optAlign", ".0"],
                ["VerticalAlign", "optVerticalAlign", ".0"],
                ["Orientation", "optOrientation", ".0"],
                ["RegionAlign", "optRegionAlign", ".0"],
                ["Rect", "optRect", ""],
                ["FrameRect", "optFrameRect", ""],
                ["IntRect", "optIntRect", ""],
            );

            foreach (type; typesMap) {
                static if (symbolTypeName == type[name]) {
                    auto fullSymbolPath = symbolPath ~ type[selector];
                    enum call = "layoutData." ~ type[accessor] ~ "(fullSymbolPath, symbol)";
                    auto value = mixin(call);

                    // assign value to widget field
                    mixin("widget." ~ symbolName ~ " = value;");
                    writeln(type[name], " value ", value, " for symbol ", symbolName);
                }
            }
        }

        writeln("------");
    }

private:
    RPDLTree layoutData;
    Manager uiManager;
}

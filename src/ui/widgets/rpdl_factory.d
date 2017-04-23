module ui.widgets.rpdl_factory;

import std.path;

import rpdl;
import rpdl.node;

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

    void createWidgets(Node widgetNode = null, Widget widget = null) {
        if (widgetNode is null)
            widgetNode = layoutData.root;

        foreach (Node childNode; widgetNode.children) {

            if (auto objectNode = cast(ObjectNode) childNode) {
                Widget newWidget = createWidgetByNode(objectNode);
                assert(newWidget !is null);
            } else {
                // TODO: throw an exception
            }
        }
    }

    Widget createWidgetByNode(ObjectNode widgetNode) {
        switch (widgetNode.name) {
            case "Panel":
                return createWidget!Panel(widgetNode);

            case "Button":
                return createWidget!Button(widgetNode);

            default:
                return null;
        }
    }

    import std.stdio;

    Widget createWidget(T : Widget)(ObjectNode widgetNode) {
        T widget = new T();

        writeln(widgetNode.name);

        foreach (Node childNode; widgetNode.children) {
            if (auto objectNode = cast(ObjectNode) childNode) {
                // if (newWidget.classinfo.name)
                // Widget newWidget = createWidget!Panel(objectNode);

                // if (uiManager !is null)
                    // uiManager.addWidget(newWidget);
            } else {
                readFields!T(widget, widgetNode);
            }
        }

        return widget;
    }

    void readFields(T : Widget)(T widget, ObjectNode widgetNode) {
        foreach (symbolName; getSymbolsNamesByUDA!(Widget, Widget.Field)) {
            auto symbol = mixin("widget." ~ symbolName);
            alias symbolType = typeof(symbol);

            const string symbolTypeName = symbolType.stringof;
            const string symbolPath = widgetNode.path ~ "." ~ symbolName;

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
                    writeln(type[name], " value ", value, " for symbol ", symbolName);
                }
            }
        }
    }

private:
    RPDLTree layoutData;
    Manager uiManager;
}

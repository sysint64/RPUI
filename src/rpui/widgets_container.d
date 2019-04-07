module rpui.widgets_container;

import std.container.array;
import rpui.widget;
import rpui.events;

package final class WidgetsContainer {
    Widget rootWidget;
    private Array!Widget widgets;
    Widget delegate(Widget) decorator = null;

    this(Widget widget) {
        this.rootWidget = widget;
    }

    package void decorateWidgets(Widget delegate(Widget) decorator) {
        if (this.decorator is null) {
            this.decorator = decorator;
        }
    }

    void deleteWidget(Widget targetWidget) {
        deleteWidget(targetWidget.id);
    }

    void deleteWidget(in size_t id) {
    }

    void addWidget(Widget widget) {
        if (decorator is null) {
            addWidgetWithoutDecorator(widget);
            return;
        }

        auto decoratedWidget = decorator(widget);
        addWidgetWithoutDecorator(decoratedWidget);
        decoratedWidget.children.addWidget(widget);
    }

    void addWidgetWithoutDecorator(Widget widget) {
        widget.view = rootWidget.view;

        widget.events.subscribeWidget(widget);
        rootWidget.events.join(widget.events, windowEvents);

        if (widgets.length == 0) {
            rootWidget.p_firstWidget = widget;
            rootWidget.p_lastWidget = widget;
        }

        // Links
        widget.p_parent = rootWidget;
        widget.owner = rootWidget;
        widget.p_nextWidget = rootWidget.p_firstWidget;
        widget.p_prevWidget = rootWidget.p_lastWidget;
        widget.p_depth = rootWidget.p_depth + 1;

        rootWidget.p_lastWidget.p_nextWidget = widget;
        rootWidget.p_firstWidget.p_prevWidget = widget;
        rootWidget.p_lastWidget = widget;

        // Insert
        widgets.insert(widget);
        rootWidget.view.widgetOrdering.insert(widget);
        // TODO:
        // widget.onCreate(CreateEvent());
    }

    @property size_t length() const {
        return widgets.length();
    }

    @property bool empty() const {
        return widgets.empty;
    }

    @property ref inout(Widget) front() inout {
        return widgets.front;
    }

    @property ref inout(Widget) back() inout {
        return widgets.back;
    }

    int opApply(int delegate(Widget) apply) {
        int result = 0;

        foreach (widget; widgets) {
            result = apply(widget);

            if (result) {
                break;
            }
        }

        return result;
    }
}

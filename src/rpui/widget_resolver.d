module rpui.widget_resolver;

import rpui.widget;

package final class WidgetResolver {
    private Widget cursor;

    this(Widget widget) {
        this.cursor = widget;
    }

    /**
     * Find the first element that satisfying the `predicate`
     * traversing up through its ancestors.
     */
    Widget closest(bool function(Widget) predicate) {
        Widget widget = cursor.parent;

        while (widget !is null) {
            if (predicate(widget))
                return widget;

            widget = widget.parent;
        }

        return null;
    }

    /**
     * Find the first element that satisfying the `predicate`
     * traversing down through its ancestors.
     */
    Widget find(bool function(Widget) predicate) {
        foreach (Widget widget; cursor.children) {
            if (predicate(widget))
                return widget;

            Widget foundWidget = widget.resolver.find(predicate);

            if (foundWidget !is null)
                return foundWidget;
        }

        return null;
    }

    Widget findWidgetByName(alias name)() {
        return find(widget => widget.name == name);
    }
}

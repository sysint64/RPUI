module rpui.widget_events;

import std.container.array;

import rpui.input;
import rpui.primitives;
import rpui.widget;
import rpui.events;
import rpui.events_observer;

struct ClickEvent {}
struct FocusEvent {}
package struct FocusFrontEvent {}
package struct FocusBackEvent {}
struct BlurEvent {}
struct ResizeEvent {}
struct ClickActionInvokedEvent {}

final class WidgetEventsObserver : EventsObserver {
    private Widget[Subscriber] widgets;

    Subscriber subscribeWidget(Widget widget) {
        auto subscriber = subscribe(widget);
        widgets[subscriber] = widget;
        return subscriber;
    }

    override bool subscriberIsNotifiable(Subscriber subscriber) {
        if (subscriber in widgets) {
            return !widgets[subscriber].isFrozen();
        } else {
            return true;
        }
    }
}

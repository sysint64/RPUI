module rpui.tests.events;

import input;
import rpui.events;
import rpui.events_observer;

version(unittest) import unit_threaded;

@("Should emit event to subscribers")
unittest {
    auto events = new EventsObserver();
    auto result = KeyCode.Unspecified;

    events.subscribe!(KeyPressedEvent)(delegate(in event) { result = event.key; });
    events.notify(KeyPressedEvent(KeyCode.A));

    result.shouldEqual(KeyCode.A);
}

@("Observer should unsubscribe events")
unittest {
    auto events = new EventsObserver();
    auto result = KeyCode.Unspecified;

    auto subscriber = events.subscribe!(KeyPressedEvent)(delegate(in event) { result = event.key; });
    events.notify(KeyPressedEvent(KeyCode.A));
    events.unsubscribe(subscriber);
    events.notify(KeyPressedEvent(KeyCode.B));
    result.shouldEqual(KeyCode.A);
}

@("Should allow exted events")
unittest {
    struct FooEvent {
        const string key;
    }

    auto events = new EventsObserver();
    string result = "bar";

    events.subscribe(delegate(in FooEvent event) { result = event.key; });
    events.notify(FooEvent("foo"));

    result.shouldEqual("foo");
}

@("Join observable")
unittest {
    auto events1 = new EventsObserver();
    auto events2 = new EventsObserver();

    auto result = KeyCode.Unspecified;

    events2.subscribe!(KeyPressedEvent)(delegate(in event) { result = event.key; });
    events1.join(events2);
    events1.notify(KeyPressedEvent(KeyCode.B));
    result.shouldEqual(KeyCode.B);
    events2.notify(KeyPressedEvent(KeyCode.A));
    result.shouldEqual(KeyCode.A);
}

@("Silent joined observer shouldn't notify")
unittest {
    auto events1 = new EventsObserver();
    auto events2 = new EventsObserver();

    auto result = KeyCode.Unspecified;

    events2.subscribe!(KeyPressedEvent)(delegate(in event) { result = event.key; });
    events1.join(events2);
    events1.notify(KeyPressedEvent(KeyCode.B));
    result.shouldEqual(KeyCode.B);
    events1.silent(events2);
    events1.notify(KeyPressedEvent(KeyCode.A));
    result.shouldEqual(KeyCode.B);
}

@("Unjoined observer shouldn't notify")
unittest {
    auto events1 = new EventsObserver();
    auto events2 = new EventsObserver();

    auto result = KeyCode.Unspecified;

    events2.subscribe!(KeyPressedEvent)(delegate(in event) { result = event.key; });
    events1.join(events2);
    events1.notify(KeyPressedEvent(KeyCode.B));
    result.shouldEqual(KeyCode.B);
    events1.unjoin(events2);
    events1.notify(KeyPressedEvent(KeyCode.A));
    result.shouldEqual(KeyCode.B);
}

module rpui.focus_navigator;

import rpui.widget;
import rpui.widget_events;

package final class FocusNavigator {
    private Widget holder;

    this (Widget widget) {
        this.holder = widget;
    }

    // NOTE: navFocusFront and navFocusBack are symmetrical
    // focusNext and focusPrev too therefore potential code reduction reductuin
    package void navFocusFront() {
        with (holder) {
            events.notify(FocusFrontEvent());

            if (skipFocus && firstWidget !is null) {
                firstWidget.focusNavigator.navFocusFront();
            } else {
                holder.focus();
            }
        }
    }

    /// Focus to the next widget.
    void focusNext() {
        with (holder) {
            if (skipFocus && isFocused) {
                navFocusFront();
                return;
            }

            if (parent.lastWidget != holder) {
                holder.nextWidget.focusNavigator.navFocusFront();
            } else {
                if (parent.finalFocus) {
                    parent.focusNavigator.navFocusFront();
                } else {
                    parent.focusNavigator.focusNext();
                }
            }
        }
    }

    package void navFocusBack() {
        with (holder) {
            events.notify(FocusBackEvent());

            if (skipFocus && lastWidget !is null) {
                lastWidget.focusNavigator.navFocusBack();
            } else {
                holder.focus();
            }
        }
    }

    /// Focus to the previous widget.
    void focusPrev() {
        with (holder) {
            if (skipFocus && isFocused) {
                navFocusBack();
                return;
            }

            if (parent.firstWidget != holder) {
                holder.prevWidget.focusNavigator.navFocusBack();
            } else {
                if (parent.finalFocus) {
                    parent.focusNavigator.navFocusBack();
                } else {
                    parent.focusNavigator.focusPrev();
                }
            }
        }
    }

    void borderScrollToWidget() {
        Widget parent = holder.parent;

        while (parent !is null) {
            auto scrollable = cast(Scrollable) parent;
            auto focusScrollNavigation = cast(FocusScrollNavigation) parent;
            parent = parent.parent;

            if (scrollable is null)
                continue;

            if (focusScrollNavigation is null) {
                scrollable.scrollToWidget(holder);
            } else {
                focusScrollNavigation.borderScrollToWidget(holder);
            }
        }
    }
}

module rpui.widgets.stack_layout.stack_locator;

import std.math;

import rpui.widget;
import rpui.primitives;
import rpui.math;

struct StackLocator {
    Widget holder;
    Orientation orientation = Orientation.vertical;

    private vec2 maxSize = vec2(0, 0);
    private vec2 lastWidgetPosition = vec2(0, 0);
    private Widget lastWidgetInStack = null;

    void attach(Widget widget) {
        holder = widget;
        holder.widthType = Widget.SizeType.wrapContent;
        holder.heightType = Widget.SizeType.wrapContent;
        setDecorator();
    }

    private void setDecorator() {
        holder.children.decorateWidgets(delegate(Widget widget) {
            Widget cell = new Widget();
            cell.associatedWidget = widget;
            cell.skipFocus = true;
            return cell;
        });
    }

    void updateWidgetsPosition() {
        with (holder) {
            startWidgetsPositioning();

            foreach (Widget cell; children) {
                pushWidgetPosition(cell);
            }
        }
    }

    void startWidgetsPositioning() {
        lastWidgetPosition = vec2(0, 0);
        lastWidgetInStack = null;
    }

    void pushWidgetPosition(Widget cell) {
        with (holder) {
            lastWidgetInStack = cell.firstWidget;

            if (orientation == Orientation.vertical) {
                cell.widthType = SizeType.matchParent;
                cell.size.y = lastWidgetInStack.outerSize.y;
                cell.position.y = lastWidgetPosition.y;
                cell.updateSize();
            } else {
                cell.size.x = lastWidgetInStack.outerSize.x;
                cell.heightType = SizeType.matchParent;
                cell.position.x = lastWidgetPosition.x;
                cell.updateSize();
            }

            lastWidgetPosition += lastWidgetInStack.size + lastWidgetInStack.outerOffsetEnd;

            if (lastWidgetInStack.widthType != SizeType.matchParent) {
                maxSize.x = fmax(maxSize.x, lastWidgetInStack.outerSize.x);
            }

            if (lastWidgetInStack.heightType != SizeType.matchParent) {
                maxSize.y = fmax(maxSize.y, lastWidgetInStack.outerSize.y);
            }
        }
    }

    void updateSize() {
        with (holder) {
            if (orientation == Orientation.vertical) {
                if (widthType == SizeType.wrapContent) {
                    size.x = maxSize.x > innerSize.x ? maxSize.x : innerSize.x;
                }

                if (heightType == SizeType.wrapContent) {
                    if (lastWidgetInStack !is null) {
                        size.y = lastWidgetPosition.y + lastWidgetInStack.outerOffset.bottom + innerOffsetSize.y;
                    } else {
                        // TODO(Andrey): why *2 ?
                        size.y = innerOffsetSize.y * 2;
                    }
                }
            }

            if (orientation == Orientation.horizontal) {
                if (heightType == SizeType.wrapContent) {
                    size.y = maxSize.y > innerSize.y ? maxSize.y : innerSize.y;
                }

                if (widthType == SizeType.wrapContent) {
                    if (lastWidgetInStack !is null) {
                        size.x = lastWidgetPosition.x + lastWidgetInStack.outerOffset.right + innerOffsetSize.x;
                    }
                }
            }
        }
    }
}

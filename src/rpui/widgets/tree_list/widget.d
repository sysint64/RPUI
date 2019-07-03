module rpui.widgets.tree_list.widget;

import rpui.primitives;
import rpui.math;
import rpui.widget;
import rpui.events;
import rpui.widgets.tree_list_node.widget;

class TreeList : Widget {
    private TreeListNode selectedNode_ = null;
    @property TreeListNode selected() { return selectedNode_; }

    @field bool drawLines = true;

    struct Measure {
        float computedWrapHeight = 0;
        float nodeLeftOffset;
    }

    Measure measure;

    this(in string style = "TreeList") {
        super(style);
    }

    override void onCreate() {
        super.onCreate();

        with (view.theme.tree) {
            measure.nodeLeftOffset = data.getNumber(style ~ ".nodeLeftOffset.0");
        }
    }

    override void onProgress(in ProgressEvent event) {
        super.onProgress(event);
    }

    override void updateSize() {
        super.updateSize();

        if (heightType == SizeType.wrapContent) {
            measure.computedWrapHeight = 0;
            computeWrapHeight(this);
            size.y = measure.computedWrapHeight;
        }
    }

    private void computeWrapHeight(Widget root) {
        foreach (Widget widget; root.children) {
            TreeListNode node = cast(TreeListNode) widget;

            if (node !is null) {
                measure.computedWrapHeight += widget.size.y;

                if (node.isOpen) {
                    computeWrapHeight(widget);
                }
            } else {
                measure.computedWrapHeight += widget.size.y;
                computeWrapHeight(widget);
            }
        }
    }
}

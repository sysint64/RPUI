module rpui.widgets.tree_list.widget;

import rpui.primitives;
import rpui.math;
import rpui.widget;
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
}

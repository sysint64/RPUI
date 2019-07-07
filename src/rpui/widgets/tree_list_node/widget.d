module rpui.widgets.tree_list_node.widget;

import rpui.events;
import rpui.primitives;
import rpui.math;
import rpui.widget;
import rpui.widgets.button.widget;
import rpui.widgets.tree_list.widget;
import rpui.widgets.tree_list_node.renderer;

class TreeListNode : Button {
    @field bool isOpen = true;
    @field bool allowHide = true;

    @property TreeList treeList() { return treeList_; }
    private TreeList treeList_;

    private float innerHeight;
    private bool lastDepth = 0;
    package bool isExpandButtonEnter = false;

    this(in string style = "TreeListNode") {
        super(style);
        textAlign = Align.left;
        drawChildren = true;
        renderer = new TreeListNodeRenderer("TreeList");
    }

    override void onCreate() {
        super.onCreate();
        setTreeList();
    }

    private void setTreeList() {
        if (auto treeList = cast(TreeList) parent) {
            treeList_ = treeList;
        } else {
            auto treeListNode = cast(TreeListNode) parent;
            treeList_ = treeListNode.treeList;
        }
    }

    override void onRender() {
        renderer.onRender();
    }

    override void onProgress(in ProgressEvent event) {
        debug assert(treeList !is null);

        super.onProgress(event);

        locator.updateAbsolutePosition();
        position.x = treeList.measure.nodeLeftOffset;

        innerHeight = size.y;

        if (!isOpen)
            return;

        foreach (Widget widget; children) {
            auto treeListNode = cast(TreeListNode) widget;

            if (treeListNode is null)
                continue;

            treeListNode.position.y = innerHeight;
            innerHeight += treeListNode.innerHeight;
            treeListNode.onProgress(event);
        }

        updateSize();
    }

    protected override void updateSize() {
        overSize.y = innerHeight;
        size.x = treeList.size.x - treeDepth * 20;
        size.y = 21;
    }

    @property uint treeDepth() {
        return depth - treeList.depth;
    }

    override void onMouseDown(in MouseDownEvent event) {
        super.onMouseDown(event);

        if (isExpandButtonEnter) {
            isOpen = !isOpen;
        }
    }
}

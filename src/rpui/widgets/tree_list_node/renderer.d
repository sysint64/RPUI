module rpui.widgets.tree_list_node.renderer;

import rpui.theme;
import rpui.events;
import rpui.widget;
import rpui.math;
import rpui.widgets.button.renderer;
import rpui.widgets.tree_list_node.widget;
import rpui.render.components;
import rpui.render.components_factory;
import rpui.render.renderer;
import rpui.render.transforms;

final class TreeListNodeRenderer : ButtonRenderer {
    private TreeListNode widget;
    private Theme theme;
    private const string treeListStyle;

    private bool needUpdateLines = true;

    this(in string treeListStyle) {
        this.treeListStyle = treeListStyle;
    }

    override void onCreate(Widget widget, in string style) {
        super.onCreate(widget, style);

        this.theme = widget.view.theme;
        this.widget = cast(TreeListNode) widget;

        //     treeLinesRenderObject = renderFactory.createLines(true);
        //     linesGeometry = treeLinesRenderObject.geometry;

        //     with (linesGeometry) {
        //         addVertex(vec2(0.0f, 0.0f));
        //         addVertex(vec2(0.0f, 0.0f));
        //         addVertex(vec2(0.0f, 0.0f));
        //         addVertex(vec2(0.0f, 0.0f));

        //         addIndices([0, 1, 2, 3]);
        //     }

        //     linesGeometry.createGeometry();

    }

    override void onRender() {
        super.onRender();
    }

    // override void render(Camera camera) {
    //     super.render(camera);

    //     if (treeDepth <= 2) {
    //         renderer.renderColoredObject(
    //             treeLinesRenderObject,
    //             treeList.linesColor,
    //             absolutePosition,
    //             vec2(1.0f, 1.0f)
    //         );
    //     }
    // }

    override void onProgress(in ProgressEvent event) {
        super.onProgress(event);
        // if (treeDepth <= 2)
            // updateLines();
    }

    // private void updateLines() {
    //     const length = parent == treeList ? treeList.rootLineLength : treeList.lineLength;
    //     const isFirst = this == parent.children.front;
    //     const halfHeight = height / 2.0f - 1.0f;  // -1 due-to line height

    //     if (treeDepth == 2) {
    //         const deltaBeetwenNodes = absolutePosition.y - prevWidget.absolutePosition.y;

    //         // TODO: -1 is magic a number and it's just adjustment for root node line.
    //         const top = isFirst ? halfHeight - 1.0f : deltaBeetwenNodes;


    //         linesGeometry.updateIndices([0, 1, 2, 3]);
    //         linesGeometry.updateVertices([
    //             vec2(0.0f, -halfHeight),
    //             vec2(-length, -halfHeight),
    //             vec2(-length, -halfHeight),
    //             vec2(-length, -halfHeight + top),
    //         ]);
    //     } else {
    //         linesGeometry.updateIndices([0, 1]);
    //         linesGeometry.updateVertices([
    //             vec2(0.0f, -halfHeight),
    //             vec2(-length, -halfHeight)
    //         ]);
    //     }

    //     needUpdateLines = false;
    // }
}

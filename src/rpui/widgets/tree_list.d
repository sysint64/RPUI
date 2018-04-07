/**
 * Copyright: © 2017 RedGoosePaws
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 * Authors: Andrey Kabylin
 */

module rpui.widgets.tree_list;

import gapi;
import basic_types;
import math.linalg;

import rpui.widget;
import rpui.manager;
import rpui.render_objects;

import rpui.widgets.button;

class TreeListNode : Button {
    private TreeList p_treeList;
    @property TreeList treeList() { return p_treeList; }

    @Field bool isOpen = true;
    @Field bool allowHide = true;

    this(in string style = "TreeListNode") {
        super(style);
        textAlign = Align.left;
        drawChildren = true;
    }

    override void onCreate() {
        super.onCreate();

        setTreeList();

        treeLinesRenderObject = renderFactory.createLines(true);
        linesGeometry = treeLinesRenderObject.geometry;

        with (linesGeometry) {
            addVertex(vec2(0.0f, 0.0f));
            addVertex(vec2(0.0f, 0.0f));
            addVertex(vec2(0.0f, 0.0f));
            addVertex(vec2(0.0f, 0.0f));

            addIndices([0, 1, 2, 3]);
        }

        linesGeometry.createGeometry();
    }

    private void setTreeList() {
        if (auto treeList = cast(TreeList) parent) {
            p_treeList = treeList;
        } else {
            auto treeListNode = cast(TreeListNode) parent;
            p_treeList = treeListNode.treeList;
        }
    }

    override void render(Camera camera) {
        super.render(camera);

        if (treeDepth <= 2) {
            renderer.renderColoredObject(
                treeLinesRenderObject,
                treeList.linesColor,
                absolutePosition,
                vec2(1.0f, 1.0f)
            );
        }
    }

    override void progress() {
        debug assert(treeList !is null);

        super.progress();
        locator.updateAbsolutePosition();
	position.x = treeList.nodeLeftOffset;

        innerHeight = size.y;
        treeList.computedWrapHeight += size.y;

        if (!isOpen)
            return;

        foreach (Widget widget; children) {
            auto treeListNode = cast(TreeListNode) widget;

            if (treeListNode is null)
                continue;

            treeListNode.position.y = innerHeight;
            innerHeight += treeListNode.innerHeight;
            treeListNode.progress();
        }

        updateSize();

        if (treeDepth <= 2)
            updateLines();
    }

    private void updateLines() {
        const length = parent == treeList ? treeList.rootLineLength : treeList.lineLength;
        const isFirst = this == parent.children.front;
        const halfHeight = height / 2.0f - 1.0f;  // -1 due-to line height

        if (treeDepth == 2) {
            const deltaBeetwenNodes = absolutePosition.y - prevWidget.absolutePosition.y;

            // TODO: -1 is magic a number and it's just adjustment for root node line.
            const top = isFirst ? halfHeight - 1.0f : deltaBeetwenNodes;

            linesGeometry.updateIndices([0, 1, 2, 3]);
            linesGeometry.updateVertices([
                vec2(0.0f, -halfHeight),
                vec2(-length, -halfHeight),
                vec2(-length, -halfHeight),
                vec2(-length, -halfHeight + top),
            ]);
        } else {
            linesGeometry.updateIndices([0, 1]);
            linesGeometry.updateVertices([
                vec2(0.0f, -halfHeight),
                vec2(-length, -halfHeight)
            ]);
        }

        needUpdateLines = false;
    }

    private bool needUpdateLines = true;

    protected override void updateSize() {
        overSize.y = innerHeight;
        size.x = treeList.size.x - treeDepth * 20;
        size.y = 21;
    }

    @property uint treeDepth() {
        return depth - treeList.depth;
    }

private:
    BaseRenderObject openCloseStateRenderObject;
    BaseRenderObject treeLinesRenderObject;
    Geometry linesGeometry;
    float innerHeight;
    bool lastDepth = 0;
}

class TreeList : Widget {
    private TreeListNode p_selected = null;
    @property TreeListNode selected() { return p_selected; }

    @Field bool drawLines = true;

    this(in string style = "TreeList") {
        super(style);
    }

    override void onCreate() {
        super.onCreate();

        with (manager.theme.tree) {
            linesColor = data.getNormColor(style ~ ".linesColor");
            lineLength = data.getNumber(style ~ ".lineLength.0");
            rootLineLength = data.getNumber(style ~ ".rootLineLength.0");
            nodeLeftOffset = data.getNumber(style ~ ".nodeLeftOffset.0");
        }
    }

package:
    vec4 linesColor;
    float computedWrapHeight = 0;
    float lineLength;
    float rootLineLength;
    float nodeLeftOffset;
}

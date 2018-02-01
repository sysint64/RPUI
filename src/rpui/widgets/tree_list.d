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
    package TreeList p_treeList = null;
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

        treeLinesRenderObject = renderFactory.createLines(true);
        linesGeometry = treeLinesRenderObject.geometry;

        with (linesGeometry) {
            addVertex(vec2(0.0f, 0.0f));
            addVertex(vec2(0.0f, 100.0f));
            addVertex(vec2(0.0f, 100.0f));
            addVertex(vec2(100.0f, 100.0f));

            addIndices([0, 1, 2, 3]);
        }

        // linesGeometry.linearFillIndices();
        linesGeometry.createGeometry();
    }

    override void render(Camera camera) {
        super.render(camera);

        renderer.renderColoredObject(
            treeLinesRenderObject,
            treeList.linesColor,
            absolutePosition,
            vec2(1.0f, 1.0f)
        );
    }

    override void onProgress() {
        debug assert(treeList !is null);

        super.onProgress();
        updateAbsolutePosition();
	position.x = 20;

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
            treeListNode.onProgress();
        }

        updateSize();

        // Lines
        linesGeometry.updateIndices([0, 1]);
        linesGeometry.updateVertices([
            vec2(0.0f, 0.0f),
            vec2(100.0f, 100.0f),
        ]);
    }

    override void addWidget(Widget widget) {
        super.addWidget(widget);

        if (auto treeListNode = cast(TreeListNode) widget) {
            treeListNode.p_treeList = p_treeList;
        }
    }

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

    override void addWidget(Widget widget) {
        super.addWidget(widget);

        if (auto treeListNode = cast(TreeListNode) widget) {
            treeListNode.p_treeList = this;
        }
    }

    override void onCreate() {
        super.onCreate();

        with (manager.theme.tree) {
            linesColor = data.getNormColor(style ~ ".linesColor");
            elementMargin = data.getNumber(style ~ ".margin.0");
            rootElementMargin = data.getNumber(style ~ ".rootMargin.0");
        }
    }

package:
    vec4 linesColor;
    float rootElementMargin;
    float elementMargin;
    float computedWrapHeight = 0;
}

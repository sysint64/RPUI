module rpui.widgets.tree_list_node.renderer;

import std.container.array;
import std.math;

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

    private vec4 linesColor;
    private float lineLength;
    private float rootLineLength;

    private LinesGeometry lines;
    private Array!vec2 vertices;
    private Array!uint indices;
    private LinesTransforms linesTransforms;

    private bool needUpdateLines = true;

    this(in string treeListStyle) {
        this.treeListStyle = treeListStyle;
    }

    override void onCreate(Widget widget, in string style) {
        super.onCreate(widget, style);

        this.theme = widget.view.theme;
        this.widget = cast(TreeListNode) widget;

        auto data = theme.tree.data;

        linesColor = data.getNormColor(treeListStyle ~ ".linesColor");
        lineLength = data.getNumber(treeListStyle ~ ".lineLength.0");
        rootLineLength = data.getNumber(treeListStyle ~ ".rootLineLength.0");

        vertices.reserve(4);
        indices.reserve(4);

        vertices.insert(vec2(0.0f, 0.0f));
        vertices.insert(vec2(0.0f, 0.0f));
        vertices.insert(vec2(0.0f, 0.0f));
        vertices.insert(vec2(0.0f, 0.0f));

        indices.insert(0);
        indices.insert(1);
        indices.insert(2);
        indices.insert(3);

        lines = createDynamicLinesGeometry(vertices, indices);
    }

    override void onRender() {
        super.onRender();

        if (widget.treeDepth > 2)
            return;

        renderColorLines(theme, lines, linesColor, linesTransforms);
    }

    override void onProgress(in ProgressEvent event) {
        super.onProgress(event);

        if (widget.treeDepth > 2)
            return;

        linesTransforms = updateLinesTransforms(widget.view.cameraView, widget.absolutePosition);
        updateLines();
    }

    private void updateLines() {
        with (widget) {
            const length = parent == treeList ? rootLineLength : lineLength;
            const isFirst = widget == parent.children.front;
            const halfHeight = round(height / 2.0f) - 1.0f;  // -1 due-to line height

            if (treeDepth == 2) {
                const deltaBeetwenNodes = absolutePosition.y - prevWidget.absolutePosition.y;

                // NOTE(Andrey): -1 it's a just adjustment for root node line.
                const top = isFirst ? halfHeight - 1.0f : deltaBeetwenNodes;

                vertices.clear();
                vertices.insert(vec2(0.0f, -halfHeight));
                vertices.insert(vec2(-length, -halfHeight));
                vertices.insert(vec2(-length, -halfHeight));
                vertices.insert(vec2(-length, -halfHeight + top));

                indices.clear();
                indices.insert(0);
                indices.insert(1);
                indices.insert(2);
                indices.insert(3);
            } else {
                vertices.clear();
                vertices.insert(vec2(0.0f, -halfHeight));
                vertices.insert(vec2(-length, -halfHeight));

                indices.clear();
                indices.insert(0);
                indices.insert(1);
            }

            updateLinesGeometryData(lines, vertices, indices);
            needUpdateLines = false;
        }
    }
}

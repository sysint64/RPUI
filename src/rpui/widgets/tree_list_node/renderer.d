module rpui.widgets.tree_list_node.renderer;

import std.container.array;
import std.math;

import gapi.texture;

import rpui.basic_rpdl_exts;
import rpui.primitives;
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
    private float enterExpandButtonAlpha;
    private float leaveExpandButtonAlpha;
    private vec2 expandButtonOffset;
    private FrameRect expandButtonBorders;

    private LinesGeometry lines;
    private Array!vec2 vertices;
    private Array!uint indices;
    private LinesTransforms linesTransforms;
    private TextureQuad expandButton;
    private OriginalWithNormilizedTextureCoords expandButtonOpenTexCoords;
    private OriginalWithNormilizedTextureCoords expandButtonCloseTexCoords;
    private QuadTransforms expandButtonTransforms;

    private bool needUpdateLines = true;

    this(in string treeListStyle) {
        this.treeListStyle = treeListStyle;
    }

    override void onCreate(Widget widget, in string style) {
        super.onCreate(widget, style);

        this.theme = widget.view.theme;
        this.widget = cast(TreeListNode) widget;

        auto data = theme.tree.data;

        expandButton = createUiSkinTextureQuad(theme);
        expandButtonOpenTexCoords = createOriginalWithNormilizedTextureCoordsFromRdpl(
            theme,
            style ~ ".openIcon"
        );
        expandButtonCloseTexCoords = createOriginalWithNormilizedTextureCoordsFromRdpl(
            theme,
            style ~ ".closeIcon"
        );

        linesColor = data.getNormColor(treeListStyle ~ ".linesColor");
        lineLength = data.getNumber(treeListStyle ~ ".lineLength.0");
        rootLineLength = data.getNumber(treeListStyle ~ ".rootLineLength.0");
        enterExpandButtonAlpha = data.getNumber(style ~ ".enterExpandButtonAlpha.0");
        leaveExpandButtonAlpha = data.getNumber(style ~ ".leaveExpandButtonAlpha.0");
        expandButtonOffset = data.getVec2f(style ~ ".expandButtonOffset");
        expandButtonBorders = data.getFrameRect(style ~ ".expandButtonBorders");

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

        if (widget.treeDepth <= 2) {
            renderColorLines(theme, lines, linesColor, linesTransforms);
        }

        if (widget.isOpen) {
            widget.renderChildren();
        }

        renderExpandButton();
    }

    private void renderExpandButton() {
        if (widget.children.empty) {
            return;
        }

        Texture2DCoords expandButtonTexCoord;

        if (widget.isOpen) {
            expandButtonTexCoord = expandButtonOpenTexCoords.normilizedTexCoords;
        } else {
            expandButtonTexCoord = expandButtonCloseTexCoords.normilizedTexCoords;
        }

        renderTexAtlasQuad(
            theme,
            expandButton.geometry,
            expandButton.texture,
            expandButtonTexCoord,
            expandButtonTransforms,
            widget.isExpandButtonEnter ? enterExpandButtonAlpha : leaveExpandButtonAlpha
        );
    }

    override void onProgress(in ProgressEvent event) {
        super.onProgress(event);

        if (widget.treeDepth <= 2) {
            linesTransforms = updateLinesTransforms(widget.view.cameraView, widget.absolutePosition);
            updateLines();
        }

        updateExpandButton();
    }

    private void updateExpandButton() {
        const length = widget.parent == widget.treeList ? rootLineLength : lineLength;

        const position = widget.absolutePosition + vec2(-length, 0) + expandButtonOffset;
        const size = expandButtonOpenTexCoords.originalTexCoords.size;

        expandButtonTransforms = updateQuadTransforms(
            widget.view.cameraView,
            position,
            size
        );

        widget.isExpandButtonEnter = pointInRect(
            widget.view.mousePos,
            Rect(position, size)
        );
    }

    private void updateLines() {
        with (widget) {
            const length = parent == treeList ? rootLineLength : lineLength;
            const isFirst = widget == parent.children.front;
            const halfHeight = round(height / 2.0f) - 1.0f;  // -1 due-to line height
            const currentExpandButtonBorders = widget.children.empty
                ? FrameRect()
                : expandButtonBorders;
            const currentPrevWidgetExpandButtonBorders = prevWidget.children.empty
                ? FrameRect()
                : expandButtonBorders;

            if (treeDepth == 2) {
                const deltaBeetwenNodes = absolutePosition.y - prevWidget.absolutePosition.y;

                // NOTE(Andrey): -1 it's a just adjustment for root node line.
                const top = isFirst ? halfHeight - 1.0f : deltaBeetwenNodes;

                vertices.clear();
                vertices.insert(vec2(0.0f, -halfHeight));
                vertices.insert(vec2(-length + currentExpandButtonBorders.right, -halfHeight));
                vertices.insert(vec2(-length, -halfHeight + currentExpandButtonBorders.top));
                vertices.insert(vec2(-length, -halfHeight + top - currentPrevWidgetExpandButtonBorders.bottom));

                indices.clear();
                indices.insert(0);
                indices.insert(1);
                indices.insert(2);
                indices.insert(3);
            } else {
                vertices.clear();
                vertices.insert(vec2(0.0f, -halfHeight));
                vertices.insert(vec2(-length + currentExpandButtonBorders.right, -halfHeight));

                indices.clear();
                indices.insert(0);
                indices.insert(1);
            }

            updateLinesGeometryData(lines, vertices, indices);
            needUpdateLines = false;
        }
    }
}

module rpui.widgets.panel.render_system;

import rpui.theme;
import rpui.widgets.panel;
import rpui.widgets.panel.transforms_system;

import gapi.texture;
import gapi.vec;
import gapi.geometry;
import rpui.render_objects;
import rpui.render_factory;
import rpui.renderer;

enum SplitColor {
    darkInner,
    darkOuter,
    lightInner,
    lightOuter,
}

struct RenderData {
    vec4[Panel.Background] backgroundColors;
    vec4[SplitColor] splitColors;
    Texture2DCoords headerOpenMarkTexCoords;
    Texture2DCoords headerCloseMarkTexCoords;
    vec2 headerMarkSize;
    vec2 headerMarkPosition;

    Geometry background;
    Geometry splitInner;
    Geometry splitOuter;
    StatefulChain horizontalScrollButton;
    StatefulChain verticalScrollButton;
    StatefulTexAtlasTextureQuad headerBackground;
    TextureQuad headerMark;
    StatefulUiText headerText;
}

final class PanelRenderSystem : RenderSystem {
    private Panel widget;
    private Theme theme;
    private RenderTransforms* transforms;
    private RenderData* renderData;

    this(Panel widget, RenderData* renderData, RenderTransforms* transforms) {
        this.widget = widget;
        this.theme = widget.view.theme;
        this.transforms = transforms;
        this.renderData = renderData;
    }

    override void onRender() {
        renderBackground();
        renderHeader();

        if (!widget.isOpen) {
            renderSplit();
            return;
        }

        widget.renderChildren();
        renderSplit();
        renderScrollButtons();
    }

    private void renderBackground() {
        if (widget.background == Panel.Background.transparent) {
            return;
        }

        renderColorQuad(
            theme,
            renderData.background,
            renderData.backgroundColors[widget.background],
            transforms.background
        );
    }

    private void renderScrollButtons() {
        if (widget.horizontalScrollButton.visible) {
            renderHorizontalChain(
                theme,
                renderData.horizontalScrollButton.parts,
                renderData.horizontalScrollButton.texCoords[widget.horizontalScrollButton.state],
                transforms.horizontalScrollButton
            );
        }

        if (widget.verticalScrollButton.visible) {
            renderVerticalChain(
                theme,
                renderData.verticalScrollButton.parts,
                renderData.verticalScrollButton.texCoords[widget.verticalScrollButton.state],
                transforms.verticalScrollButton
            );
        }
    }

    private void renderSplit() {
        if (!widget.showSplit)
            return;

        const innerColor = widget.darkSplit
            ? renderData.splitColors[SplitColor.darkInner]
            : renderData.splitColors[SplitColor.lightInner];

        const outerColor = widget.darkSplit
            ? renderData.splitColors[SplitColor.darkOuter]
            : renderData.splitColors[SplitColor.lightOuter];

        renderColorQuad(
            theme,
            renderData.splitInner,
            innerColor,
            transforms.splitInner
        );

        renderColorQuad(
            theme,
            renderData.splitOuter,
            outerColor,
            transforms.splitOuter
        );
    }

    private void renderHeader() {
        if (!widget.userCanHide)
            return;

        renderTexAtlasQuad(
            theme,
            renderData.headerBackground.geometry,
            renderData.headerBackground.texture,
            renderData.headerBackground.texCoords[widget.headerState].normilizedTexCoords,
            transforms.headerBackground
        );

        Texture2DCoords markTexCoords;

        if (widget.isOpen) {
            markTexCoords = renderData.headerOpenMarkTexCoords;
        } else {
            markTexCoords = renderData.headerCloseMarkTexCoords;
        }

        renderTexAtlasQuad(
            theme,
            renderData.headerMark.geometry,
            renderData.headerMark.texture,
            markTexCoords,
            transforms.headerMark
        );

        renderUiText(
            theme,
            renderData.headerText.render,
            renderData.headerText.attrs[widget.headerState],
            transforms.headerText,
        );
    }
}

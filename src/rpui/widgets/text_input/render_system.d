module rpui.widgets.text_input.render_system;

import std.container.array;

import rpui.widgets.text_input.widget;
import rpui.widgets.text_input.transforms_system;
import rpui.render.components_factory;
import rpui.render.components;
import rpui.render.renderer;
import rpui.theme;
import rpui.math;
import rpui.primitives;

import gapi.texture;

struct RenderData {
    StatefulChain background;
    Chain focusGlow;
    TexAtlasTextureQuad carriage;
    StatefulTexAtlasTextureQuad leftArrow;
    StatefulTexAtlasTextureQuad rightArrow;
    StatefulUiText text;
    StatefulUiText prefix;
    StatefulUiText postfix;
    Geometry selectRegion;
    vec4 selectRegionColor;
    vec4 selectedTextColor;
}

final class TextInputRenderSystem : RenderSystem {
    private TextInput widget;
    private Theme theme;
    private RenderTransforms* transforms;
    private RenderData* renderData;

    this(TextInput widget, RenderData* renderData, RenderTransforms* transforms) {
        this.widget = widget;
        this.theme = widget.view.theme;
        this.transforms = transforms;
        this.renderData = renderData;
    }

    override void onRender() {
        renderBackground();
        renderPrefix();
        renderPostfix();
        pushScissor();
        renderText();
        renderSoftPostfix();
        renderSelectRegion();
        renderSelectedText();
        widget.view.popScissor();
        renderArrows();
        renderCarriage();
    }

    private void pushScissor() {
        with (widget) {
            Rect scissor;

            const leftMargin = measure.textLeftMargin + widget.measure.prefixWidth;
            const rightMargin = measure.textRightMargin + widget.measure.postfixWidth;

            scissor.point = vec2(
                absolutePosition.x + leftMargin,
                absolutePosition.y
            );
            scissor.size = vec2(
                size.x - leftMargin - rightMargin,
                size.y
            );

            view.pushScissor(scissor);
        }
    }

    private void renderBackground() {
        renderData.background.state = widget.state;

        renderHorizontalChain(
            theme,
            renderData.background,
            transforms.background,
            widget.partDraws
        );

        if (widget.focusable && widget.isFocused) {
            renderHorizontalChain(
                theme,
                renderData.focusGlow,
                transforms.focusGlow,
                widget.partDraws
            );
        }
    }

    private void renderArrows() {
        if (!widget.isNumberMode())
            return;

        renderTexAtlasQuad(
            theme,
            renderData.leftArrow,
            transforms.leftArrow
        );

        renderTexAtlasQuad(
            theme,
            renderData.rightArrow,
            transforms.rightArrow
        );
    }

    private void renderCarriage() {
        if (!widget.isFocused)
            return;

        if (widget.editComponent.carriage.visible) {
            renderTexAtlasQuad(
                theme,
                renderData.carriage,
                transforms.carriage
            );
        }
    }

    private void renderPrefix() {
        if (widget.prefix != "") {
            renderData.prefix.state = widget.state;
            renderUiText(theme, renderData.prefix, transforms.prefix);
        }
    }

    private void renderPostfix() {
        if (widget.postfix != "" && !widget.softPostfix) {
            renderData.postfix.state = widget.state;
            renderUiText(theme, renderData.postfix, transforms.postfix);
        }
    }

    private void renderSoftPostfix() {
        if (widget.postfix != "" && widget.softPostfix) {
            renderData.postfix.state = widget.state;
            renderUiText(theme, renderData.postfix, transforms.postfix);
        }
    }

    private void renderText() {
        renderData.text.state = widget.state;
        renderUiText(theme, renderData.text, transforms.text);
    }

    private void renderSelectedText() {
        if (!widget.editComponent.selectRegion.textIsSelected())
            return;

        const scissor = Rect(
            widget.editComponent.selectRegion.absolutePosition,
            widget.editComponent.selectRegion.size
        );

        widget.view.pushScissor(scissor);
        auto attrs = renderData.text.attrs[widget.state];
        attrs.color = renderData.selectedTextColor;

        renderUiText(
            theme,
            renderData.text.render,
            attrs,
            transforms.text
        );

        widget.view.popScissor();
    }

    private void renderSelectRegion() {
        if (!widget.editComponent.selectRegion.textIsSelected())
            return;

        renderColorQuad(
            theme,
            renderData.selectRegion,
            renderData.selectRegionColor,
            transforms.selectRegion
        );
    }
}

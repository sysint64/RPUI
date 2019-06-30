module rpui.widgets.multiline_label.renderer;

import std.container.array;
import std.string;
import std.array;
import std.math;

import rpui.math;
import rpui.primitives;
import rpui.theme;
import rpui.events;
import rpui.widget;
import rpui.widgets.multiline_label.widget;
import rpui.render.components;
import rpui.render.components_factory;
import rpui.render.renderer;
import rpui.render.transforms;

final class MultilineLabelRenderer : Renderer {
    private Array!UiText lines;
    private Array!UiTextTransforms textTransforms;
    private MultilineLabel widget;
    private Theme theme;
    private utf32string lastCaption;

    override void onCreate(Widget widget) {
        this.theme = widget.view.theme;
        this.widget = cast(MultilineLabel) widget;
    }

    override void onRender() {
        for (size_t i = 0; i < lines.length; ++i) {
            const transforms = textTransforms[i];
            const text = lines[i];
            renderUiText(theme, text.render, text.attrs, transforms);
        }
    }

    override void onProgress(in ProgressEvent event) {
        if (lastCaption != widget.caption) {
            updateLines();
            lastCaption = widget.caption;
        }

        const textLineHeight = widget.measure.lineHeight * widget.lineHeightFactor;
        float textCurrentPosY = getStartTextPosY(textLineHeight);

        widget.measure.maxLineWidth = 0;
        widget.measure.lineHeight = 0;

        for (size_t i = 0; i < lines.length; ++i) {
            const textPos = vec2(widget.innerOffsetStart.x + widget.absolutePosition.x, textCurrentPosY);
            const textSizeY = textLineHeight;
            const textSize = vec2(widget.size.x - widget.innerOffsetSize.x, textSizeY);
            textCurrentPosY += textSizeY;

            with (lines[i].attrs) {
                textAlign = widget.textAlign;
                textVerticalAlign = widget.textVerticalAlign;
            }

            textTransforms[i] = updateUiTextTransforms(
                &lines[i].render,
                &theme.regularFont,
                textTransforms[i],
                lines[i].attrs,
                widget.view.cameraView,
                textPos,
                textSize
            );

            if (widget.measure.maxLineWidth < textTransforms[i].size.x) {
                widget.measure.maxLineWidth = textTransforms[i].size.x;
            }

            if (widget.measure.lineHeight < textTransforms[i].size.y) {
                widget.measure.lineHeight = textTransforms[i].size.y;
            }
        }

        widget.measure.linesCount = lines.length;
    }

    private float getStartTextPosY(in float textLineHeight) {
        const boundaryHeight = textLineHeight * lines.length;
        float textPosY = widget.absolutePosition.y;

        switch (widget.textVerticalAlign) {
            case VerticalAlign.bottom:
                textPosY += widget.size.y - boundaryHeight - widget.innerOffsetEnd.y;
                break;

            case VerticalAlign.middle:
                textPosY += round((widget.size.y - boundaryHeight) * 0.5);
                break;

            default:
                textPosY += widget.innerOffsetStart.y;
                break;
        }

        return textPosY;
    }

    private void updateLines() {
        textTransforms.clear();
        const strings = lineSplitter(widget.caption).array;

        lines.length = strings.length;
        textTransforms.length = strings.length;

        for (size_t i = 0; i < lines.length; ++i) {
            lines[i] = createUiTextFromRdpl(theme, widget.style, "Regular");
            lines[i].attrs.caption = strings[i];
        }
    }
}

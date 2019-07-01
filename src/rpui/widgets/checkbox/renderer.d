module rpui.widgets.checkbox.renderer;

import rpui.math;
import rpui.theme;
import rpui.events;
import rpui.widget;
import rpui.widgets.checkbox.widget;
import rpui.render.components;
import rpui.render.components_factory;
import rpui.render.renderer;
import rpui.render.transforms;

final class CheckboxRenderer : Renderer {
    private StatefulUiText text;
    private StatefulTexAtlasTextureQuad checkedBox;
    private StatefulTexAtlasTextureQuad uncheckedBox;
    private TexAtlasTextureQuad focusGlow;
    private QuadTransforms boxTransforms;
    private QuadTransforms focusGlowTransforms;
    private UiTextTransforms textTransforms;
    private Checkbox widget;
    private Theme theme;
    private vec2 focusOffsets;

    private inout(State) getTextState() inout {
        return widget.isEnter ? State.enter : State.leave;
    }

    private void updateState() {
        text.state = getTextState();
        checkedBox.state = getTextState();
        uncheckedBox.state = getTextState();
    }

    override void onCreate(Widget widget, in string style) {
        this.theme = widget.view.theme;
        this.widget = cast(Checkbox) widget;

        text = createStatefulUiTextFromRdpl(
            theme,
            style,
            "Text",
            [State.leave, State.enter]
        );

        checkedBox = createStatefulTexAtlasTextureQuadFromRdpl(
            theme,
            style,
            "checkedBox",
            [State.leave, State.enter]
        );

        uncheckedBox = createStatefulTexAtlasTextureQuadFromRdpl(
            theme,
            style,
            "uncheckedBox",
            [State.leave, State.enter]
        );

        focusGlow = createTexAtlasTextureQuadFromRdpl(
            theme,
            style,
            "Focus.glow"
        );

        focusOffsets = theme.tree.data.getVec2f(style ~ ".Focus.offsets");
    }

    override void onRender() {
        updateState();
        renderUiText(theme, text, textTransforms);

        if (widget.checked) {
            renderTexAtlasQuad(theme, checkedBox, boxTransforms);
        } else {
            renderTexAtlasQuad(theme, uncheckedBox, boxTransforms);
        }

        if (widget.isFocused) {
            renderTexAtlasQuad(theme, focusGlow, focusGlowTransforms);
        }
    }

    override void onProgress(in ProgressEvent event) {
        updateText();
        updateBox();
    }

    private void updateText() {
        UiTextAttributes* textAttrs = &text.attrs[getTextState()];

        with (textAttrs) {
            caption = widget.caption;
            textAlign = widget.textAlign;
            textVerticalAlign = widget.textVerticalAlign;
        }

        textTransforms = updateUiTextTransforms(
            &text.render,
            &theme.regularFont,
            textTransforms,
            *textAttrs,
            widget.view.cameraView,
            widget.absolutePosition + widget.innerOffsetStart,
            widget.size
        );

        widget.measure.textWidth = textTransforms.size.x + textAttrs.offset.x;
        widget.measure.lineHeight = textTransforms.size.y + textAttrs.offset.y;
    }

    private void updateBox() {
        boxTransforms = updateQuadTransforms(
            widget.view.cameraView,
            widget.absolutePosition,
            uncheckedBox.texCoords[State.leave].originalTexCoords.size
        );

        const focusPos = widget.absolutePosition + focusOffsets;

        focusGlowTransforms = updateQuadTransforms(
            widget.view.cameraView,
            focusPos,
            focusGlow.texCoords.originalTexCoords.size
        );
    }
}

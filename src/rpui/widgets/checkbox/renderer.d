module rpui.widgets.checkbox.renderer;

import rpui.math;
import rpui.theme;
import rpui.events;
import rpui.widget;
import rpui.widgets.checkbox;
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

    override void onCreate(Widget widget) {
        this.theme = widget.view.theme;
        this.widget = cast(Checkbox) widget;

        text = createStatefulUiTextFromRdpl(
            theme,
            widget.style,
            "Text",
            [State.leave, State.enter]
        );

        checkedBox = createStatefulTexAtlasTextureQuadFromRdpl(
            theme,
            widget.style,
            "checkedBox",
            [State.leave, State.enter]
        );

        uncheckedBox = createStatefulTexAtlasTextureQuadFromRdpl(
            theme,
            widget.style,
            "uncheckedBox",
            [State.leave, State.enter]
        );

        focusGlow = createTexAtlasTextureQuadFromRdpl(
            theme,
            widget.style,
            "Focus.glow"
        );

        focusOffsets = theme.tree.data.getVec2f(widget.style ~ ".Focus.offsets");
    }

    override void onRender() {
        renderUiText(
            theme,
            text.render,
            text.attrs[getTextState()],
            textTransforms,
        );

        const(StatefulTexAtlasTextureQuad)* box;

        if (widget.checked) {
            box = &checkedBox;
        } else {
            box = &uncheckedBox;
        }

        renderTexAtlasQuad(
            theme,
            box.geometry,
            box.texture,
            box.texCoords[getTextState()].normilizedTexCoords,
            boxTransforms
        );

        if (widget.isFocused) {
            renderTexAtlasQuad(
                theme,
                focusGlow.geometry,
                focusGlow.texture,
                focusGlow.texCoords.normilizedTexCoords,
                focusGlowTransforms
            );
        }
    }

    override void onProgress(in ProgressEvent event) {
        updateText();
        updateBox();
    }

    private void updateText() {
        with (text.attrs[getTextState()]) {
            caption = widget.caption;
            textAlign = widget.textAlign;
            textVerticalAlign = widget.textVerticalAlign;
        }

        textTransforms = updateUiTextTransforms(
            &text.render,
            &theme.regularFont,
            textTransforms,
            text.attrs[getTextState()],
            widget.view.cameraView,
            widget.absolutePosition + widget.innerOffsetStart,
            widget.size
        );

        widget.measure.textWidth = textTransforms.size.x + text.attrs[getTextState()].offset.x;
        widget.measure.lineHeight = textTransforms.size.y + text.attrs[getTextState()].offset.y;
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

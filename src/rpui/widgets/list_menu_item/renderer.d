module rpui.widgets.list_menu_item.renderer;

import std.conv;

import rpui.primitives;
import rpui.theme;
import rpui.events;
import rpui.widget;
import rpui.math;
import rpui.widgets.button.renderer;
import rpui.widgets.list_menu_item.widget;
import rpui.render.components;
import rpui.render.components_factory;
import rpui.render.renderer;
import rpui.render.transforms;

final class ListMenuItemRenderer : ButtonRenderer {
    private ListMenuItem widget;
    private Theme theme;

    private vec2 submenuArrowOffset;
    private float arrowAreaWidth;
    private StatefulTexAtlasTextureQuad arrow;
    private QuadTransforms arrowTransforms;
    private StatefulUiText shortcutText;
    private UiTextTransforms shortcutTextTransforms;

    override void onCreate(Widget widget, in string style) {
        super.onCreate(widget, style);

        this.theme = widget.view.theme;
        this.widget = cast(ListMenuItem) widget;

        arrow = createStatefulTexAtlasTextureQuadFromRdpl(theme, style, "submenuArrow");
        submenuArrowOffset = theme.tree.data.getVec2f(style ~ ".submenuArrowOffset");
        arrowAreaWidth = theme.tree.data.getNumber(style ~ ".arrowAreaWidth.0");
        shortcutText = createStatefulUiTextFromRdpl(theme, style, "ShortcutText");
    }

    override void onRender() {
        super.onRender();
        shortcutText.state = widget.state;

        if (widget.shortcut != "") {
            renderUiText(theme, shortcutText, shortcutTextTransforms);
        }

        if (widget.menu is null)
            return;

        renderTexAtlasQuad(theme, arrow, arrowTransforms);
    }

    override void onProgress(in ProgressEvent event) {
        super.onProgress(event);

        updateShortcutText();

        if (widget.menu is null)
            return;

        const arrowSize = arrow.currentTexCoords.originalTexCoords.size;
        const arrowPosition = widget.absolutePosition + vec2(widget.size.x - arrowSize.x, 0);

        arrow.state = widget.state;
        arrowTransforms = updateQuadTransforms(
            widget.view.cameraView,
            arrowPosition,
            arrowSize
        );
    }

    private void updateShortcutText() {
        if (widget.shortcut.length == 0)
            return;

        with (shortcutText.attrs[widget.state]) {
            if (widget.shortcut[0] == '@') {
                const shortcutPath = widget.shortcut[1 .. $];
                caption = to!dstring(widget.view.shortcuts.getShourtcutString(shortcutPath));
            } else {
                caption = to!dstring(widget.shortcut);
            }

            textAlign = Align.right;
            textVerticalAlign = widget.textVerticalAlign;
        }

        auto shortcutTransforms = transformSystem.getCaptonTransforms(Align.right);

        if (widget.menu !is null) {
            shortcutTransforms.position.x -= arrowAreaWidth;
        }

        shortcutTextTransforms = updateUiTextTransforms(
            &shortcutText.render,
            &theme.regularFont,
            shortcutTextTransforms,
            shortcutText.attrs[widget.state],
            widget.view.cameraView,
            shortcutTransforms.position,
            shortcutTransforms.size
        );
    }
}

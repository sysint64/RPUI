module rpui.widgets.text_input.renderer;

import rpdl.tree;

import rpui.primitives;
import rpui.theme;
import rpui.events;
import rpui.widget;
import rpui.widgets.text_input;
import rpui.widgets.text_input.render_system;
import rpui.widgets.text_input.transforms_system;
import rpui.render.components;
import rpui.render.components_factory;
import rpui.render.renderer;
import rpui.render.transforms;

final class TextInputRenderer : Renderer {
    private UiText text;
    private UiTextTransforms textTransforms;
    private TextInput widget;
    private Theme theme;
    private TextInputRenderSystem renderSystem;
    private TextInputTransformsSystem transformsSystem;
    private RenderData renderData;
    private RenderTransforms transforms;

    override void onCreate(Widget widget) {
        this.theme = widget.view.theme;
        this.widget = cast(TextInput) widget;

        renderSystem = new TextInputRenderSystem(this.widget, &renderData, &transforms);
        transformsSystem = new TextInputTransformsSystem(this.widget, &renderData, &transforms);

        loadRenderData(widget.view.theme, widget.style);
        this.widget.editComponent.attach(this.widget, transformsSystem);
    }

    private void loadRenderData(Theme theme, in string style) {
        auto data = theme.tree.data;

        renderData.background = createStatefulChainFromRdpl(theme, Orientation.horizontal, style);
        renderData.focusGlow = createChainFromRdpl(theme, Orientation.horizontal, style ~ ".Focus");
        renderData.carriage = createTexAtlasTextureQuadFromRdpl(theme, style, "carriage");
        renderData.text = createStatefulUiTextFromRdpl(theme, style, "Text");
        renderData.selectRegion = createGeometry();
        renderData.selectRegionColor = data.getNormColor(style ~ ".selectColor");
        renderData.selectedTextColor = data.getNormColor(style ~ ".selectedTextColor");

        transforms.focusOffsets = data.getVec2f(style ~ ".Focus.offsets.0");
        transforms.focusResize = data.getNumber(style ~ ".Focus.offsets.1");
        transforms.selectRegionHeight = data.getNumber(style ~ ".selectRegionHeight.0");
        transforms.selectRegionOffset = data.getVec2f(style ~ ".selectRegionOffset");
    }

    override void onRender() {
        renderSystem.onRender();
    }

    override void onProgress(in ProgressEvent event) {
        transformsSystem.onProgress(event);
    }
}

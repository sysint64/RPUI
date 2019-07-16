module rpui.widgets.tab_layout.renderer;

import rpui.math;
import rpui.events;
import rpui.theme;
import rpui.widget;
import rpui.widgets.tab_layout.widget;
import rpui.widgets.tab_button.widget;
import rpui.render.components;
import rpui.render.components_factory;
import rpui.render.transforms;
import rpui.render.renderer;

final class TabLayoutRenderer : Renderer {
    private TabLayout widget;

    private Theme theme;
    private vec4 borderColor;
    private Geometry border;
    private QuadTransforms borderTransforms;

    override void onCreate(Widget widget, in string style) {
        this.widget = cast(TabLayout) widget;
        this.theme = widget.view.theme;
        this.borderColor = theme.tree.data.getNormColor(style ~ ".borderColor");
        this.border = createGeometry();
    }

    override void onProgress(in ProgressEvent event) {
        borderTransforms = updateQuadTransforms(
            widget.view.cameraView,
            widget.absolutePosition + vec2(-widget.outerOffsetStart.x, widget.size.y - 1),
            vec2(widget.outerSize.x, 1)
        );
    }

    override void onRender() {
        TabButton activeTab = null;

        foreach (Widget child; widget.children) {
            TabButton tab = cast(TabButton) child.associatedWidget;

            if (tab !is null) {
                if (tab.checked) {
                    activeTab = tab;
                } else {
                    tab.onRender();
                }
            }
        }

        if (widget.showBorder) {
            renderColorQuad(theme, border, borderColor, borderTransforms);
        }

        if (activeTab !is null) {
            activeTab.onRender();
        }
    }
}

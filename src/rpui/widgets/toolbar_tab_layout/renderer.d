module rpui.widgets.toolbar_tab_layout.renderer;

import rpui.math;
import rpui.events;
import rpui.theme;
import rpui.widget;
import rpui.widgets.toolbar_tab_layout.widget;
import rpui.widgets.toolbar_tab_button.widget;
import rpui.render.components;
import rpui.render.components_factory;
import rpui.render.transforms;
import rpui.render.renderer;

final class ToolbarTabLayoutRenderer : Renderer {
    private ToolbarTabLayout widget;
    private Theme theme;

    override void onCreate(Widget widget, in string style) {
        this.widget = cast(ToolbarTabLayout) widget;
        this.theme = widget.view.theme;
    }

    override void onProgress(in ProgressEvent event) {
        // Nothing
    }

    override void onRender() {
        ToolbarTabButton activeTab = null;

        foreach (Widget child; widget.children) {
            ToolbarTabButton tab = cast(ToolbarTabButton) child.associatedWidget;

            if (tab !is null) {
                if (tab.checked) {
                    activeTab = tab;
                } else {
                    child.onRender();
                }
            } else {
                child.onRender();
            }
        }

        if (activeTab !is null) {
            widget.view.queryRenderWidgetInFront(activeTab);
        }
    }
}

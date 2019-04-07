module rpui.widgets.rpdl_factory;

import rpdl;
import rpdl.node;

import rpui.widget;
import rpui.view;

/// Factory for construction view from rpdl layout data.
final class RPDLWidgetFactory {
    /// Root view widget - container for other widgets.
    @property Widget rootWidget() { return rootWidget_; }
    private Widget rootWidget_;

    private RpdlTree layoutData;
    private View view;

}

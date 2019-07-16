module rpui.widgets.main_menu.widget;

import rpui.primitives;
import rpui.events;
import rpui.widget;
import rpui.widgets.stack_layout.stack_locator;

final class MainMenu : Widget {
    private StackLocator stackLocator;

    this(in string style = "ChainLayout") {
        super(style);

        heightType = SizeType.wrapContent;
        skipFocus = true;
        stackLocator.attach(this);
        stackLocator.orientation = Orientation.horizontal;
        finalFocus = true;
    }

    override void onProgress(in ProgressEvent event) {
        super.onProgress(event);

        locator.updateLocationAlign();
        locator.updateVerticalLocationAlign();
        locator.updateRegionAlign();
        locator.updateAbsolutePosition();

        updateSize();
    }

    override void updateSize() {
        super.updateSize();

        stackLocator.updateWidgetsPosition();
        stackLocator.updateSize();
    }
}

module rpui.widgets.dialog.widget;

import rpui.primitives;
import rpui.basic_rpdl_exts;
import rpui.widget;
import rpui.events;
import rpui.widgets.panel.widget;
import rpui.widgets.dialog.renderer;

final class Dialog : Widget {
    @field utf32string caption = "Dialog";
    @field bool closeOnClickOutsideArea = false;
    @field bool draggable = false;
    @field bool resizable = false;

    private bool isHeaderClick = false;

    this(in string style = "Dialog") {
        super(style);
        skipFocus = true;
        finalFocus = true;
        renderer = new DialogRenderer();
    }

    protected override void onCreate() {
        super.onCreate();

        isVisible = false;

        with (view.theme.tree) {
            extraInnerOffset = data.getFrameRect(style ~ ".extraInnerOffset");
            extraInnerOffset.top += data.getNumber(style ~ ".headerHeight.0");

            const gaps = data.getFrameRect(style ~ ".gaps");

            extraInnerOffset.left += gaps.left;
            extraInnerOffset.top += gaps.top;
            extraInnerOffset.right += gaps.right;
            extraInnerOffset.bottom += gaps.bottom;
        }
    }

    override void updateSize() {
        super.updateSize();

        if (heightType == SizeType.wrapContent) {
            size.y = innerBoundarySize.y;
        }

        if (widthType == SizeType.wrapContent) {
            size.x = innerBoundarySize.x;
        }
    }

    override void onMouseDown(in MouseDownEvent event) {
        if (!isOver && closeOnClickOutsideArea && isVisible) {
            close();
        } else {
            super.onMouseDown(event);
        }
    }

    void open() {
        isVisible = true;
        freezeUI(false);
        focusNavigator.focusPrimary();
    }

    void close() {
        isVisible = false;
        unfreezeUI();
    }
}

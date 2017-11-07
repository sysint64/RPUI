/**
 * Macros:
 * CURSOR_IMG = <img src="https://tronche.com/gui/x/xlib/appendix/b/$1" style="max-width: 16px; max-height: 16px; display: block; margin: auto">
 */

module ui.cursor;

import x11.Xlib;
import x11_cursorfont;

import application;


class Cursor {
    enum Icon {
        none = -1,
        hand = XC_hand1,  /// $(CURSOR_IMG 58.gif)
        normal = XC_left_ptr,  /// $(CURSOR_IMG 68.gif)
        iBeam = XC_xterm,  /// $(CURSOR_IMG 152.gif)
        vDoubleArrow = XC_sb_v_double_arrow,  /// $(CURSOR_IMG 116.gif)
        hDoubleArrow  = XC_sb_h_double_arrow,  /// $(CURSOR_IMG 108.gif)
        crossHair = XC_crosshair,  /// $(CURSOR_IMG 34.gif)
        drag = XC_fleur,  /// $(CURSOR_IMG 52.gif)
        topSide = XC_top_side,  /// $(CURSOR_IMG 138.gif)
        bottomSide = XC_bottom_side,  /// $(CURSOR_IMG 16.gif)
        leftSide = XC_left_side,  /// $(CURSOR_IMG 70.gif)
        rightSide = XC_right_side,  /// $(CURSOR_IMG 96.gif)
        topLeftCorner = XC_top_left_corner,  /// $(CURSOR_IMG 134.gif)
        topRightCorner = XC_top_right_corner,  /// $(CURSOR_IMG 136.gif)
        bottomLeftCorner = XC_bottom_left_corner,  /// $(CURSOR_IMG 12.gif)
        bottomRightCorner = XC_bottom_right_corner  /// $(CURSOR_IMG 14.gif)
    };

    this() {
        app = Application.getInstance();

        version (linux) {
            display = XOpenDisplay(null);
        }
    }

    @property Icon icon() { return icon_; }
    @property void icon(in Icon newIcon) {
        if (this.icon_ == newIcon)
            return;

        this.icon_ = newIcon;

        version (linux) {
            cursor = XCreateFontCursor(display, cast(uint) this.icon_);
            XDefineCursor(display, app.windowHandle, cursor);
            XFlush(display);
        }
    }

private:
    Application app;
    Icon icon_ = Icon.normal;

    version (linux) {
        Display *display;
        ulong cursor;
    }
}

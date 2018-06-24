/**
 * System cursor.
 *
 * Copyright: © 2017 Andrey Kabylin
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 *
 * Macros:
 *     CURSOR_IMG = <img src="https://tronche.com/gui/x/xlib/appendix/b/$1" style="max-width: 16px; max-height: 16px; display: block; margin: auto">
 */

module rpui.cursor;

import x11.Xlib;
import x11_cursorfont;

import application;

/// System cursor.
final class Cursor {
    enum Icon {
        none = -1,
        inherit = -2,
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
    }

    this() {
        app = Application.getInstance();

        version (linux) {
            display = XOpenDisplay(null);
        }
    }

    private Icon p_icon = Icon.normal;
    @property Icon icon() { return p_icon; }

    /// Invoke OS specified methods to update system cursor icon.
    @property void icon(in Icon newIcon) {
        if (p_icon == newIcon || p_icon == Icon.none || newIcon == Icon.inherit)
            return;

        p_icon = newIcon;

        version (linux) {
            cursor = XCreateFontCursor(display, cast(uint) p_icon);
            XDefineCursor(display, app.windowHandle, cursor);
            XFlush(display);
        }
    }

private:
    Application app;

    version (linux) {
        Display *display;
        ulong cursor;
    }
}

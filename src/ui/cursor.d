module ui.cursor;

import x11.Xlib;
import x11_cursorfont;

import application;


class Cursor {
    enum Icon {
        none = -1,
        hand = XC_hand1,
        normal = XC_left_ptr,
        iBeam = XC_xterm,
        vDoubleArrow = XC_sb_v_double_arrow,
        hDoubleArrow  = XC_sb_h_double_arrow,
        crossHair = XC_crosshair,
        drag = XC_fleur,
        topSide = XC_top_side,
        bottomSide = XC_bottom_side,
        leftSide = XC_left_side,
        rightSide = XC_right_side,
        topLeftCorner = XC_top_left_corner,
        topRightCorner = XC_top_right_corner,
        bottomLeftCorner = XC_bottom_left_corner,
        bottomRightCorner = XC_bottom_right_corner
    };

    this() {
        app = Application.getInstance();

        version (linux) {
            display = XOpenDisplay(null);
        }
    }

    @property Icon icon() { return p_icon; }

    @property void icon(in Icon icon) {
        if (p_icon == icon)
            return;

        p_icon = icon;

        version (linux) {
            cursor = XCreateFontCursor(display, cast(uint) p_icon);
            XDefineCursor(display, app.windowHandle, cursor);
            XFlush(display);
        }
    }

private:
    Application app;
    Icon p_icon = Icon.normal;

    version (linux) {
        Display *display;
        ulong cursor;
    }
}

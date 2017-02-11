module ui.cursor;

import x11.Xlib;
import x11_cursorfont;


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
}

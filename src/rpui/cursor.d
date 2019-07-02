/**
 * System cursor.
 * Macros:
 *     CURSOR_IMG = <img src="https://tronche.com/gui/x/xlib/appendix/b/$1" style="max-width: 16px; max-height: 16px; display: block; margin: auto">
 */

module rpui.cursor;

import derelict.sdl2.sdl;

enum CursorIcon {
    none = -1,
    inherit = -2,
    hand = SDL_SYSTEM_CURSOR_HAND,  /// $(CURSOR_IMG 58.gif)
    normal = SDL_SYSTEM_CURSOR_ARROW,  /// $(CURSOR_IMG 68.gif)
    iBeam = SDL_SYSTEM_CURSOR_IBEAM,  /// $(CURSOR_IMG 152.gif)
    vDoubleArrow = SDL_SYSTEM_CURSOR_SIZENS,  /// $(CURSOR_IMG 116.gif)
    hDoubleArrow  = SDL_SYSTEM_CURSOR_SIZEWE,  /// $(CURSOR_IMG 108.gif)
    crossHair = SDL_SYSTEM_CURSOR_CROSSHAIR,  /// $(CURSOR_IMG 34.gif)
    // drag = XC_fleur,  /// $(CURSOR_IMG 52.gif)
    // topSide = XC_top_side,  /// $(CURSOR_IMG 138.gif)
    // bottomSide = XC_bottom_side,  /// $(CURSOR_IMG 16.gif)
    // leftSide = XC_left_side,  /// $(CURSOR_IMG 70.gif)
    // rightSide = XC_right_side,  /// $(CURSOR_IMG 96.gif)
    // topLeftCorner = XC_top_left_corner,  /// $(CURSOR_IMG 134.gif)
    // topRightCorner = XC_top_right_corner,  /// $(CURSOR_IMG 136.gif)
    // bottomLeftCorner = XC_bottom_left_corner,  /// $(CURSOR_IMG 12.gif)
    // bottomRightCorner = XC_bottom_right_corner  /// $(CURSOR_IMG 14.gif)
}

/// System cursor.
final class CursorManager {
    private SDL_Cursor* cursor = null;

    ~this() {
        if (cursor !is null) {
            // SDL_FreeCursor(cursor);
        }
    }

    private CursorIcon icon = CursorIcon.normal;

    void setIcon(in CursorIcon newIcon) {
        if (icon == newIcon || newIcon == CursorIcon.none)
            return;

        icon = newIcon;
        CursorIcon sdlIcon;

        if (newIcon == CursorIcon.inherit) {
            sdlIcon = CursorIcon.normal;
        } else {
            sdlIcon = newIcon;
        }

        if (cursor !is null) {
            // SDL_FreeCursor(cursor);
        }

        // cursor = SDL_CreateSystemCursor(cast(SDL_SystemCursor) sdlIcon);
        // SDL_SetCursor(cursor);
    }
}

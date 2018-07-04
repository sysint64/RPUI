module rpui.clipboard_sfml;

import rpui.clipboard;
import basic_types;

// TODO: CSFML Not released yet.
class SFMLClipboard : Clipboard {
    void copyText(in utf32string text) {
    }

    utf32string pasteText() {
        return "";
    }
}

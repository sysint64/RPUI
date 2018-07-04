module rpui.clipboard;

import basic_types;

interface Clipboard {
    void copyText(in utf32string text);

    utf32string pasteText();
}

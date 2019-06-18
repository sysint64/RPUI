module rpui.resources.fonts;

import std.path;
import gapi.font;
import rpui.paths;

final class FontsRes {
    const Paths paths;
    private Font[string] fonts;

    this() {
        this.paths = createPathes();
    }

    ~this() {
        foreach (Font font; fonts) {
            deleteFont(font);
        }
    }


}

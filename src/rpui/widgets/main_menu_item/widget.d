module rpui.widgets.main_menu_item.widget;

import rpui.widgets.drop_list_menu.widget;
import rpui.widgets.main_menu.widget;
import rpui.events;

final class MainMenuItem : DropListMenu {
    this(in string style = "MainMenuItem", in string iconsGroup = "icons") {
        super(style, iconsGroup);
        skipFocus = true;
    }

    private @property MainMenu mainMenu() {
        return cast(MainMenu) this.parent.parent;
    }

    override void onProgress(in ProgressEvent event) {
        super.onProgress(event);

        if (isEnter && mainMenu.isOpen) {
            focus();
            dropMenu();
        }
    }
}

module ui.rpdl_extensions;

import ui.cursor;
import ui.widgets.panel.widget;

import rpdl.accessors;
import rpdl.exception;

class NotPanelBackgroundException : RPDLException {
    this() { super("it is not a Panel.Background value"); }
    this(in string details) { super(details); }
}


class NotCursorIconException : RPDLException {
    this() { super("it is not a Cursor.Icon value"); }
    this(in string details) { super(details); }
}

alias getPanelBackground = ufcsGetEnum!(Panel.Background, NotPanelBackgroundException);
alias optPanelBackground = ufcsOptEnum!(Panel.Background, NotPanelBackgroundException);

alias getCursorIcon = ufcsGetEnum!(Cursor.Icon, NotCursorIconException);
alias optCursorIcon = ufcsOptEnum!(Cursor.Icon, NotCursorIconException);

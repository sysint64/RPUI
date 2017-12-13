/**
 * Additional accessors for rpdl.
 *
 * Copyright: © 2017 RedGoosePaws
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 * Authors: Andrey Kabylin
 */

module rpui.rpdl_extensions;

import rpui.cursor;
import rpui.widget;
import rpui.widgets.panel;

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

class NotSizeTypeException : RPDLException {
    this() { super("it is not a Widget.SizeType value"); }
    this(in string details) { super(details); }
}

/// Retrieve `rpui.widgets.panel.Panel.Background` from rpdl tree.
alias getPanelBackground = ufcsGetEnum!(Panel.Background, NotPanelBackgroundException);

/// Optional retrieve `rpui.widgets.panel.Panel.Background` from rpdl tree.
alias optPanelBackground = ufcsOptEnum!(Panel.Background, NotPanelBackgroundException);

/// Retrieve `rpui.cursor.Cursor.Icon` from rpdl tree.
alias getCursorIcon = ufcsGetEnum!(Cursor.Icon, NotCursorIconException);

/// Optional retrieve `rpui.cursor.Cursor.Icon` from rpdl tree.
alias optCursorIcon = ufcsOptEnum!(Cursor.Icon, NotCursorIconException);

/// Retrieve `rpui.widget.Widget.SizeType` from rpdl tree.
alias getWidgetSizeType = ufcsGetEnum!(Widget.SizeType, NotSizeTypeException);

/// Optional retrieve `rpui.widget.Widget.SizeType` from rpdl tree.
alias optWidgetSizeType = ufcsOptEnum!(Widget.SizeType, NotSizeTypeException);

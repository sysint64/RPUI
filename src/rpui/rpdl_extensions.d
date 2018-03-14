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

/// Retrieve `rpui.widgets.panel.Panel.Background` from rpdl tree.
alias getPanelBackground = ufcsGetEnum!(Panel.Background);

/// Optional retrieve `rpui.widgets.panel.Panel.Background` from rpdl tree.
alias optPanelBackground = ufcsOptEnum!(Panel.Background);

/// Retrieve `rpui.cursor.Cursor.Icon` from rpdl tree.
alias getCursorIcon = ufcsGetEnum!(Cursor.Icon);

/// Optional retrieve `rpui.cursor.Cursor.Icon` from rpdl tree.
alias optCursorIcon = ufcsOptEnum!(Cursor.Icon);

/// Retrieve `rpui.widget.Widget.SizeType` from rpdl tree.
alias getWidgetSizeType = ufcsGetEnum!(Widget.SizeType);

/// Optional retrieve `rpui.widget.Widget.SizeType` from rpdl tree.
alias optWidgetSizeType = ufcsOptEnum!(Widget.SizeType);

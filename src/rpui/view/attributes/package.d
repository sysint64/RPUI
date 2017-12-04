/**
 * View configuration attributes.
 *
 * Copyright: © 2017 RedGoosePaws
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 * Authors: Andrey Kabylin
 */

module rpui.view.attributes;

public import rpui.view.attributes.accessors;
public import rpui.view.attributes.events;

/// Attachs the shortcut placed in `shortcutPath` to the view method.
struct Shortcut {
    string shortcutPath;  /// Rpdl path where shorcut declared.
}

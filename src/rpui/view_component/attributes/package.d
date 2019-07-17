/**
 * View configuration attributes.
 *
 * Copyright: © 2017 Andrey Kabylin
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 */

module rpui.view_component.attributes;

public import rpui.view_component.attributes.accessors;
public import rpui.view_component.attributes.events;

/// Attachs the shortcut placed in `value` to the view method.
struct shortcut {
    string value;  /// Rpdl path where shorcut declared.
    bool retrieve = true;  /// Whether retrieve from rpdl or set manualy
}

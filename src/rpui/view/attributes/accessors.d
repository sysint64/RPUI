/**
 * Accessors to widgets.
 *
 * Copyright: © 2017 RedGoosePaws
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 * Authors: Andrey Kabylin
 */

module rpui.view.attributes.accessors;

/**
 * Finds widget by `widgetName` and store it to annotated variable.
 * if `widgetName` is empty then widget will be extracted by annotated variable name.
 *
 * Example:
 * ---
 * @ViewWidget Button okButton;
 * @ViewWidget("cancelButton") Button closeButton;
 *
 * // Without attribute
 * okButton = manager.findWidgetByName("okButton");
 * manager.findWidgetByName("cancelButton");
 * ---
 */
struct ViewWidget {
    /// Widget name if is empty then retrieving name will be from variable name
    string widgetName = "";
}

/**
 * Finds widget by `widgetName` and store them children to annotated variable.
 * if `widgetName` is empty then widget will be finds by annotated variable name.
 *
 * Example:
 * ---
 * @GroupViewWidgets Button[3] buttons;
 *
 * // Without attribute
 * auto parent = manager.findWidgetByName("buttons");
 * int i = 0;
 *
 * foreach (child; parent.children) {
 *     buttons[i] = child;
 *     i += 1;
 * }
 * ---
 */
struct GroupViewWidgets {
    /// Widget name if is empty then retrieving name will be from variable name
    string widgetName = "";
}

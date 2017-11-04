module ui.views.attributes;

import std.traits;


// Events
struct OnClickListener { string widgetName; }
struct OnDblClickListener { string widgetName; }
struct OnFocusListener { string widgetName; }
struct OnBlurListener { string widgetName; }
struct OnKeyPressedListener { string widgetName; }
struct OnKeyReleasedListener { string widgetName; }
struct OnTextEnteredListener { string widgetName; }
struct OnMouseMoveListener { string widgetName; }
struct OnMouseWheelListener { string widgetName; }
struct OnMouseEnterListener { string widgetName; }
struct OnMouseLeaveListener { string widgetName; }
struct OnMouseDownListener { string widgetName; }
struct OnMouseUpListener { string widgetName; }

// Accessors
struct ViewWidget { string widgetName = ""; }
struct GroupViewWidgets { string widgetName = ""; }

// Shortcuts
struct Shortcut { string shortcutPath; }

module rpui.input;

import derelict.sdl2.sdl;
import std.string;

/// break the dependence on SFML Mouse
enum MouseButton {
    mouseNone = -1,
    mouseLeft = SDL_BUTTON_LEFT,
    mouseRight = SDL_BUTTON_RIGHT,
    mouseMiddle = SDL_BUTTON_MIDDLE,
}

MouseButton createMouseButtonFromSdlEvent(in SDL_Event event) {
    switch (event.button.button) {
        case SDL_BUTTON_LEFT:
            return MouseButton.mouseLeft;

        case SDL_BUTTON_RIGHT:
            return MouseButton.mouseRight;

        case SDL_BUTTON_MIDDLE:
            return MouseButton.mouseMiddle;

        default:
            return MouseButton.mouseNone;
    }
}

/// break the dependence on SDL Keyboard
enum KeyCode {
    A = SDLK_a,
    B = SDLK_b,
    C = SDLK_c,
    D = SDLK_d,
    E = SDLK_e,
    F = SDLK_f,
    G = SDLK_g,
    H = SDLK_h,
    I = SDLK_i,
    J = SDLK_j,
    K = SDLK_k,
    L = SDLK_l,
    M = SDLK_m,
    N = SDLK_n,
    O = SDLK_o,
    P = SDLK_p,
    Q = SDLK_q,
    R = SDLK_r,
    S = SDLK_s,
    T = SDLK_t,
    U = SDLK_u,
    V = SDLK_v,
    W = SDLK_w,
    X = SDLK_x,
    Y = SDLK_y,
    Z = SDLK_z,
    Num0 = SDLK_0,
    Num1 = SDLK_1,
    Num2 = SDLK_2,
    Num3 = SDLK_3,
    Num4 = SDLK_4,
    Num5 = SDLK_5,
    Num6 = SDLK_6,
    Num7 = SDLK_7,
    Num8 = SDLK_8,
    Num9 = SDLK_9,
    Escape = SDLK_ESCAPE,
    LControl = SDLK_LCTRL,
    LShift = SDLK_LSHIFT,
    LAlt = SDLK_LALT,
    LSystem = SDLK_LGUI,
    RControl = SDLK_RCTRL,
    RShift = SDLK_RSHIFT,
    RAlt = SDLK_RALT,
    RSystem = SDLK_RGUI,
    Menu = SDLK_MENU,
    LBracket = SDLK_LEFTBRACKET,
    RBracket = SDLK_RIGHTBRACKET,
    SemiColon = SDLK_SEMICOLON,
    Comma = SDLK_COMMA,
    Period = SDLK_PERIOD,
    Quote = SDLK_QUOTE,
    Slash = SDLK_SLASH,
    BackSlash = SDLK_BACKSLASH,
    Tilde = SDLK_BACKQUOTE,
    Equal = SDLK_EQUALS,
    Space = SDLK_SPACE,
    Return = SDLK_RETURN,
    BackSpace = SDLK_BACKSPACE,
    Tab = SDLK_TAB,
    PageUp = SDLK_PAGEUP,
    PageDown = SDLK_PAGEDOWN,
    End = SDLK_END,
    Home = SDLK_HOME,
    Insert = SDLK_INSERT,
    Delete = SDLK_DELETE,
    Add = SDLK_PLUS,
    Subtract = SDLK_MINUS,
    Left = SDLK_LEFT,
    Right = SDLK_RIGHT,
    Up = SDLK_UP,
    Down = SDLK_DOWN,
    Numpad0 = SDLK_KP_0,
    Numpad1 = SDLK_KP_1,
    Numpad2 = SDLK_KP_2,
    Numpad3 = SDLK_KP_3,
    Numpad4 = SDLK_KP_4,
    Numpad5 = SDLK_KP_5,
    Numpad6 = SDLK_KP_6,
    Numpad7 = SDLK_KP_7,
    Numpad8 = SDLK_KP_8,
    Numpad9 = SDLK_KP_9,
    F1 = SDLK_F1,
    F2 = SDLK_F2,
    F3 = SDLK_F3,
    F4 = SDLK_F4,
    F5 = SDLK_F5,
    F6 = SDLK_F6,
    F7 = SDLK_F7,
    F8 = SDLK_F8,
    F9 = SDLK_F9,
    F10 = SDLK_F10,
    F11 = SDLK_F11,
    F12 = SDLK_F12,
    F13 = SDLK_F13,
    F14 = SDLK_F14,
    F15 = SDLK_F15,
    Pause = SDLK_PAUSE,
    Shift = SDLK_UNKNOWN,
    Ctrl = SDLK_UNKNOWN,
    Alt = SDLK_UNKNOWN,
    Unspecified = SDLK_UNKNOWN,
}

private static bool[KeyCode] keyPressed;

void setKeyPressed(in KeyCode key, in bool pressed) {
    keyPressed[key] = pressed;

    with (KeyCode) {
        keyPressed[Shift] = isKeyPressed(LShift) || isKeyPressed(RShift);
        keyPressed[Ctrl] = isKeyPressed(LControl) || isKeyPressed(RControl);
        keyPressed[Alt] = isKeyPressed(LAlt) || isKeyPressed(RAlt);
    }
}

bool isClickKey(in KeyCode key) {
    return key == KeyCode.Return;
}

bool isKeyPressed(in KeyCode key) {
    if (key !in keyPressed)
        return false;

    return keyPressed[key];
}

bool testKeyState(in KeyCode key, in bool state) {
    if (key !in keyPressed)
        return false;

    return keyPressed[key] == state;
}

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

MouseButton createMouseButtonFromButtonSdlEvent(in SDL_Event event) {
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

MouseButton createMouseButtonFromSdlState(in Uint32 state) {
    if (state & SDL_BUTTON(SDL_BUTTON_LEFT)) {
        return MouseButton.mouseLeft;
    }
    else if (state & SDL_BUTTON(SDL_BUTTON_RIGHT)) {
        return MouseButton.mouseRight;
    }
    else if (state & SDL_BUTTON(SDL_BUTTON_MIDDLE)) {
        return MouseButton.mouseMiddle;
    }
    else {
        return MouseButton.mouseNone;
    }
}

/// break the dependence on SDL Keyboard
enum KeyCode {
    A = cast(int) SDLK_a,
    B = cast(int) SDLK_b,
    C = cast(int) SDLK_c,
    D = cast(int) SDLK_d,
    E = cast(int) SDLK_e,
    F = cast(int) SDLK_f,
    G = cast(int) SDLK_g,
    H = cast(int) SDLK_h,
    I = cast(int) SDLK_i,
    J = cast(int) SDLK_j,
    K = cast(int) SDLK_k,
    L = cast(int) SDLK_l,
    M = cast(int) SDLK_m,
    N = cast(int) SDLK_n,
    O = cast(int) SDLK_o,
    P = cast(int) SDLK_p,
    Q = cast(int) SDLK_q,
    R = cast(int) SDLK_r,
    S = cast(int) SDLK_s,
    T = cast(int) SDLK_t,
    U = cast(int) SDLK_u,
    V = cast(int) SDLK_v,
    W = cast(int) SDLK_w,
    X = cast(int) SDLK_x,
    Y = cast(int) SDLK_y,
    Z = cast(int) SDLK_z,
    Num0 = cast(int) SDLK_0,
    Num1 = cast(int) SDLK_1,
    Num2 = cast(int) SDLK_2,
    Num3 = cast(int) SDLK_3,
    Num4 = cast(int) SDLK_4,
    Num5 = cast(int) SDLK_5,
    Num6 = cast(int) SDLK_6,
    Num7 = cast(int) SDLK_7,
    Num8 = cast(int) SDLK_8,
    Num9 = cast(int) SDLK_9,
    Escape = cast(int) SDLK_ESCAPE,
    LControl = cast(int) SDLK_LCTRL,
    LShift = cast(int) SDLK_LSHIFT,
    LAlt = cast(int) SDLK_LALT,
    LSystem = cast(int) SDLK_LGUI,
    RControl = cast(int) SDLK_RCTRL,
    RShift = cast(int) SDLK_RSHIFT,
    RAlt = cast(int) SDLK_RALT,
    RSystem = cast(int) SDLK_RGUI,
    Menu = cast(int) SDLK_MENU,
    LBracket = cast(int) SDLK_LEFTBRACKET,
    RBracket = cast(int) SDLK_RIGHTBRACKET,
    SemiColon = cast(int) SDLK_SEMICOLON,
    Comma = cast(int) SDLK_COMMA,
    Period = cast(int) SDLK_PERIOD,
    Quote = cast(int) SDLK_QUOTE,
    Slash = cast(int) SDLK_SLASH,
    BackSlash = cast(int) SDLK_BACKSLASH,
    Tilde = cast(int) SDLK_BACKQUOTE,
    Equal = cast(int) SDLK_EQUALS,
    Space = cast(int) SDLK_SPACE,
    Return = cast(int) SDLK_RETURN,
    BackSpace = cast(int) SDLK_BACKSPACE,
    Tab = cast(int) SDLK_TAB,
    PageUp = cast(int) SDLK_PAGEUP,
    PageDown = cast(int) SDLK_PAGEDOWN,
    End = cast(int) SDLK_END,
    Home = cast(int) SDLK_HOME,
    Insert = cast(int) SDLK_INSERT,
    Delete = cast(int) SDLK_DELETE,
    Add = cast(int) SDLK_PLUS,
    Subtract = cast(int) SDLK_MINUS,
    Left = cast(int) SDLK_LEFT,
    Right = cast(int) SDLK_RIGHT,
    Up = cast(int) SDLK_UP,
    Down = cast(int) SDLK_DOWN,
    Numpad0 = cast(int) SDLK_KP_0,
    Numpad1 = cast(int) SDLK_KP_1,
    Numpad2 = cast(int) SDLK_KP_2,
    Numpad3 = cast(int) SDLK_KP_3,
    Numpad4 = cast(int) SDLK_KP_4,
    Numpad5 = cast(int) SDLK_KP_5,
    Numpad6 = cast(int) SDLK_KP_6,
    Numpad7 = cast(int) SDLK_KP_7,
    Numpad8 = cast(int) SDLK_KP_8,
    Numpad9 = cast(int) SDLK_KP_9,
    Super = cast(int) SDLK_APPLICATION,
    F1 = cast(int) SDLK_F1,
    F2 = cast(int) SDLK_F2,
    F3 = cast(int) SDLK_F3,
    F4 = cast(int) SDLK_F4,
    F5 = cast(int) SDLK_F5,
    F6 = cast(int) SDLK_F6,
    F7 = cast(int) SDLK_F7,
    F8 = cast(int) SDLK_F8,
    F9 = cast(int) SDLK_F9,
    F10 = cast(int) SDLK_F10,
    F11 = cast(int) SDLK_F11,
    F12 = cast(int) SDLK_F12,
    F13 = cast(int) SDLK_F13,
    F14 = cast(int) SDLK_F14,
    F15 = cast(int) SDLK_F15,
    Pause = cast(int) SDLK_PAUSE,
    Shift,
    Ctrl,
    Alt,
    Unspecified = cast(int) SDLK_UNKNOWN,
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

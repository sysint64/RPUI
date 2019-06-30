module rpui.platform;

import derelict.sdl2.sdl;

void platformShowSystemCursor() {
    SDL_ShowCursor(SDL_ENABLE);
}

void platformHideSystemCursor() {
    SDL_ShowCursor(SDL_DISABLE);
}

void platformSetMousePosition(void* window, in int x, in int y) {
    SDL_WarpMouseInWindow(cast(SDL_Window*) window, x, y);
}

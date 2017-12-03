module ftgl;

import derelict.freetype.ft;

extern (C) {
    alias FTGL_DOUBLE = double;
    alias FTGL_FLOAT = float;

    enum {
        RENDER_FRONT = 0x0001,
        RENDER_BACK  = 0x0002,
        RENDER_SIDE  = 0x0004,
        RENDER_ALL   = 0xffff
    }

    struct FTGLfont;

    FTGLfont* ftglCreateTextureFont(const char* file);
    int ftglSetFontFaceSize(FTGLfont* font, uint size, uint res);
    int ftglSetFontCharMap(FTGLfont* font, FT_Encoding encoding);
    void ftglRenderFont(FTGLfont* font, const char* str, int mode);
    void ftglGetFontBBox(FTGLfont* font, const char* str, int len, ref float[6] bounds);
}

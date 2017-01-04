module settings;

import patterns.singleton;


class Settings {
    mixin Singleton!(Settings);

    uint OGLMajor;
    uint OGLMinor;
}

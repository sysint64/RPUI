module gapi.render_pool;

import patterns.singleton;

import gapi.texture;
import gapi.shader;
import gapi.geometry;

private class RenderPool(T) {
    mixin Singleton!(RenderPool!T);

    void bind(T element) {
        if (lastBinded == element)
            return;

        lastBinded = element;
    }

    void unbind(T element) {
        element.unbind();
        lastBinded = null;
    }

private:
    T lastBinded = null;
}

alias RenderPool!Geometry GeometryPool;
alias RenderPool!Texture TexturePool;
alias RenderPool!Shader ShaderPool;

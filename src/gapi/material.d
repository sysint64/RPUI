module gapi.material;

import gapi.shader;
import gapi.texture;
import gapi.base_object;

import math.linalg;


interface Material {
    void bind(BaseObject baseObject);
    void unbind();
}


class TexAtlasMaterial : Material {
    this(Shader shader, Texture texture) {
        this.p_shader = shader;
        this.p_texture = texture;
    }

    void bind(BaseObject baseObject) {
        shader.bind();
        shader.setUniformMatrix("MVP", baseObject.lastMVPMatrix);
        shader.setUniformTexture("texture", texture);
        shader.setUniformVec2f("offset", texCoord.offset);
        shader.setUniformVec2f("size", texCoord.size);
    }

    void unbind() {
        shader.unbind();
    }

    @property ref Texture.Coord texCoord() { return p_texCoord; }
    @property void texCoord(Texture.Coord val) {
        if (val.normalized) {
            p_texCoord = val;
        } else {
            p_texCoord = val.getNrom(p_texture);
        }
    }

    @property Shader shader() { return p_shader; }
    @property void shader(Shader val) { p_shader = val; }

    @property Texture texture() { return p_texture; }
    @property void texture(Texture val) { p_texture = val; }

private:
    Shader p_shader;
    Texture p_texture;
    Texture.Coord p_texCoord;
}

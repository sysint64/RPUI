module gapi.camera;

import math.linalg;
import std.stdio;


class Camera {
    this(in float viewportWidth, in float viewportHeight) {
        this.viewportWidth  = viewportWidth;
        this.viewportHeight = viewportHeight;
    }

    void updateMatrices() {
        const vec3 eye = vec3(p_position, 1.0f);
        const vec3 target = vec3(p_position, 0.0f);
        const vec3 up = vec3(0.0f, 1.0f, 0.0f);

        p_viewMatrix = mat4.look_at(eye, target, up);
        p_projectionMatrix = mat4.orthographic(0.0f, viewportWidth,
                                               0.0f, viewportHeight,
                                               0.0f, 10.0f);

        if (p_zoom > 1.0f)
            p_modelMatrix = mat4.scaling(p_zoom, p_zoom, 1.0f);
        else
            p_modelMatrix = mat4.identity;

        p_MVPMatrix = p_projectionMatrix * p_modelMatrix * p_viewMatrix;
        p_needUpdateMatrices = false;
    }

    void update() {
        if (p_needUpdateMatrices)
            updateMatrices();
    }

    void move(float x, float y) {
        position = position + vec2(x, y);
    }

    void move(vec2 delta) {
        position = position + delta;
    }

    void rotate(float alpha) {
        rotation = rotation + alpha;
    }

    @property mat4 viewMatrix() { return p_viewMatrix; }
    @property mat4 projectionMatrix() { return p_projectionMatrix; }
    @property mat4 modelMatrix() { return p_modelMatrix; }
    @property mat4 MVPMatrix() { return p_MVPMatrix; }

    @property float zoom() { return p_zoom; }
    @property void zoom(float val) {
        p_zoom = val;
        p_needUpdateMatrices = true;
    }

    @property vec2 position() { return p_position; }
    @property void position(vec2 val) {
        p_position = val;
        p_needUpdateMatrices = true;
    }

    @property float rotation() { return p_rotation; }
    @property void rotation(float val) {
        p_rotation = val;
        p_needUpdateMatrices = true;
    }

    @property float viewportWidth() { return p_viewportWidth; }
    @property void viewportWidth(float val) {
        p_viewportWidth = val;
        p_needUpdateMatrices = true;
    }

    @property float viewportHeight() { return p_viewportHeight; }
    @property void viewportHeight(float val) {
        p_viewportHeight = val;
        p_needUpdateMatrices = true;
    }

    @property bool needUpdateMatrices() { return p_needUpdateMatrices; }

private:
    float p_zoom = 1.0f;
    vec2  p_position;
    float p_rotation;
    mat4  p_viewMatrix;
    mat4  p_projectionMatrix;
    mat4  p_modelMatrix;
    mat4  p_MVPMatrix;
    float p_viewportWidth;
    float p_viewportHeight;

    bool  p_needUpdateMatrices = true;
}

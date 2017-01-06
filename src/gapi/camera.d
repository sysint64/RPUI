module gapi.camera;

import gl3n.linalg;


class Camera {
    this(in float viewWidth, in float viewHeight) {
        this.viewWidth = viewWidth;
        this.viewHeight = viewHeight;
    }

    void updateMatrices() {
        immutable vec3 eye = vec3(p_position, 1);
        immutable vec3 target = vec3(p_position, 0);
        immutable vec3 up = vec3(0, 1, 0);

        p_viewMatrix = mat4.look_at(eye, target, up);
        p_projectionMatrix = mat4.orthographic(0.0f, p_viewWidth, 0.0f, p_viewHeight,
                                               1.0f, 10.0f);

        if (p_zoom > 1.0f)
            p_scaleMatrix = mat4.scaling(p_zoom, p_zoom, 1.0f);
        else
            p_scaleMatrix = mat4.identity;

        needUpdateMatrices = false;
    }

    void update() {
        if (needUpdateMatrices)
            updateMatrices();
    }

    void move(float x, float y) {
        position += vec2(x, y);
    }

    void move(vec2 delta) {
        position += delta;
    }

    void rotate(float alpha) {
        rotation += alpha;
    }

    @property mat4 viewMatrix() { return p_viewMatrix; }
    @property mat4 projectionMatrix() { return p_projectionMatrix; }
    @property mat4 scaleMatrix() { return p_scaleMatrix; }
    @property mat4 rotateMatrix() { return p_rotateMatrix; }

    @property ref float zoom() { return p_zoom; }
    @property void zoom(float val) {
        p_zoom = val;
        needUpdateMatrices = true;
    }

    @property ref vec2 position() { return p_position; }
    @property void position(vec2 val) {
        p_position = val;
        needUpdateMatrices = true;
    }

    @property ref float rotation() { return p_rotation; }
    @property void rotation(float val) {
        p_rotation = val;
        needUpdateMatrices = true;
    }

    @property ref float viewWidth() { return p_viewWidth; }
    @property void viewWidth(float val) {
        p_viewWidth = val;
        needUpdateMatrices = true;
    }

    @property ref float viewHeight() { return p_viewHeight; }
    @property void viewHeight(float val) {
        p_viewHeight = val;
        needUpdateMatrices = true;
    }

private:
    float p_zoom;
    vec2  p_position;
    float p_rotation;
    mat4  p_viewMatrix;
    mat4  p_projectionMatrix;
    mat4  p_scaleMatrix;
    mat4  p_rotateMatrix;
    float p_viewWidth;
    float p_viewHeight;

    bool  needUpdateMatrices = true;
}

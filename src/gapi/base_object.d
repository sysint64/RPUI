module gapi.base_object;

import gapi.geometry;
import gapi.camera;

import gl3n.linalg;


class BaseObject {
    void render() {
        if (!visible)
            return;

        if (needUpdateMatrices)
            updateMatrices();

        geometry.render();
    }

    vec2 worldToScreen(Camera camera) {
        // TODO: camera.zoom
        return position-camera.position;
    }

    void updateMatrices() {
        p_translateMatrix = mat4.translation(vec3(p_position, 0.0f));
        p_rotateMatrix = mat4.rotation(p_rotation, 0.0f, 0.0f, 1.0f);
        p_scaleMatrix = mat4.scaling(p_scaling.x, p_scaling.y, 0.0f);

        needUpdateMatrices = false;
    }

    void move(float x, float y) {
        position += vec2(x, y);
    }

    void move(vec2 delta) {
        position += delta;
    }

    void scale(float x, float y) {
        scaling += vec2(x, y);
    }

    void scale(vec2 delta) {
        scaling += delta;
    }

    void scale(float delta) {
        scaling += vec2(delta, delta);
    }

    void rotate(float alpha) {
        rotation += alpha;
    }

    @property Geometry geometry() { return p_geometry; }

    @property mat4 scaleMatrix() { return p_scaleMatrix; }
    @property mat4 rotateMatrix() { return p_rotateMatrix; }
    @property mat4 translateMatrix() { return p_translateMatrix; }

    @property ref bool visible() { return p_visible; }
    @property void visible(bool val) { p_visible = val; }

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

    @property ref vec2 scaling() { return p_scaling; }
    @property void scaling(vec2 val) {
        p_scaling = val;
        needUpdateMatrices = true;
    }

    @property ref vec2 pivot() { return p_pivot; }
    @property void pivot(vec2 val) {
        p_pivot = val;
        needUpdateMatrices = true;
    }

private:
    Geometry p_geometry;
    bool p_visible = true;

    vec2  p_position;
    float p_rotation;
    vec2  p_scaling;
    vec2  p_pivot;

    mat4  p_scaleMatrix;
    mat4  p_rotateMatrix;
    mat4  p_translateMatrix;

    bool needUpdateMatrices = true;
}

module gapi.base_object;

import gapi.geometry;
import gapi.camera;
import gapi.material;

import gl3n.linalg;
import std.stdio;


class BaseObject {
    this(Geometry geometry) {
        p_geometry = geometry;
    }

    void render(Camera camera) {
        if (!visible)
            return;

        if (lastCamera != camera) {
            lastCamera = camera;
            needUpdateMatrices = true;
        }

        if (needUpdateMatrices || camera.needUpdateMatrices)
            updateMatrices(camera);

        if (p_material !is null)
            p_material.bind(this);

        geometry.bind();
        geometry.render();
    }

    vec2 worldToScreen(Camera camera) {
        // TODO: camera.zoom
        return position-camera.position;
    }

    void updateMatrices(Camera camera) {
        mat4 translateMatrix = mat4.translation(vec3(p_position, 0.0f));
        mat4 rotateMatrix = mat4.rotation(p_rotation, 0.0f, 0.0f, 1.0f);
        mat4 scaleMatrix = mat4.scaling(p_scaling.x, p_scaling.y, 0.0f);

        p_modelMatrix = translateMatrix * rotateMatrix * scaleMatrix;
        p_lastMVPMatrix = camera.MVPMatrix * modelMatrix;

        needUpdateMatrices = false;
    }

    void move(float x, float y) {
        position = position + vec2(x, y);
    }

    void move(vec2 delta) {
        position = position + delta;
    }

    void scale(float x, float y) {
        scaling = scaling + vec2(x, y);
    }

    void scale(vec2 delta) {
        scaling = scaling + delta;
    }

    void scale(float delta) {
        scaling = scaling + vec2(delta, delta);
    }

    void rotate(float alpha) {
        rotation = rotation + alpha;
    }

    // Properties ----------------------------------------------------------------------------------

    bool visible = true;

    @property Geometry geometry() { return p_geometry; }

    @property mat4 modelMatrix() { return p_modelMatrix; }
    @property mat4 lastMVPMatrix() { return p_lastMVPMatrix; }

    @property vec2 position() { return p_position; }
    @property void position(vec2 val) {
        p_position = val;
        needUpdateMatrices = true;
    }

    @property float rotation() { return p_rotation; }
    @property void rotation(float val) {
        p_rotation = val;
        needUpdateMatrices = true;
    }

    @property vec2 scaling() { return p_scaling; }
    @property void scaling(vec2 val) {
        p_scaling = val;
        needUpdateMatrices = true;
    }

    @property vec2 pivot() { return p_pivot; }
    @property void pivot(vec2 val) {
        p_pivot = val;
        needUpdateMatrices = true;
    }

private:
    Geometry p_geometry;

    vec2  p_position = vec2(0, 0);
    float p_rotation = 0.0f;
    vec2  p_scaling;
    vec2  p_pivot;

    mat4  p_modelMatrix;
    mat4  p_lastMVPMatrix;
    Material p_material = null;
    Camera lastCamera;

    bool needUpdateMatrices = true;
}

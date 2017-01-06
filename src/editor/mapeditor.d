module editor.mapeditor;

import patterns.singleton;
import application;

import gapi.camera;
import gapi.sprite;
import gapi.shader;
import gapi.texture;
import gapi.base_object;

import math.linalg;
import std.stdio;


class MapEditor: Application {
    mixin Singleton!(MapEditor);

    override void render() {
        camera.update();

        shader.setUniformMatrix("MVP", sprite.lastMVPMatrix);
        shader.setUniformTexture("texture", texture);

        sprite.rotate(0.01f);
        // sprite.move(0.0f, 1.0f);
        sprite.render(camera);
    }

    Camera camera;
    SpriteGeometry spriteGeometry;
    BaseObject sprite;
    Shader shader;
    Texture texture;

    override void onCreate() {
        camera = new Camera(screenWidth, screenHeight);
        spriteGeometry = new SpriteGeometry();
        sprite = new BaseObject(spriteGeometry);
        shader = new Shader("C:/dev/e2dit/res/shaders/GL2/transform.glsl");
        texture = new Texture("C:/dev/e2dit/res/test.jpg");

        camera.position = vec2(0.0f, 0.0f);
        camera.zoom = 1.0f;

        sprite.position = vec2(0.0f, 0.0f);
        sprite.scaling = vec2(200.0f, 200.0f);
        sprite.rotation = 0.5f;

        shader.bind();
        texture.bind();
        spriteGeometry.bind();
    }

    override void onKeyPressed(in uint key) {
    }

    override void onKeyReleased(in uint key) {
    }

    override void onTextEntered(in uint key) {
    }

    override void onMouseDown(in uint x, in uint y, in uint button) {
    }

    override void onMouseUp(in uint x, in uint y, in uint button) {
    }

    override void onDblClick(in uint x, in uint y, in uint button) {
    }

    override void onMouseMove(in uint x, in uint y) {
    }

    override void onMouseWheel(in uint dx, in uint dy) {
    }

    override void onResize(in uint width, in uint height) {
    }
}

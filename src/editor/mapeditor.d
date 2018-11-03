module editor.mapeditor;

import input;
import patterns.singleton;
import application;
import basic_types;
import resources.strings;

import gapi.camera;
import gapi.geometry;
import gapi.geometry_factory;
import gapi.shader;
import gapi.texture;
import gapi.base_object;
import gapi.font;
import gapi.text;

import rpui;
import rpui.widget;
import rpui.widgets.button;
import rpui.widgets.stack_layout;
import rpui.widgets.panel;
import rpui.view;
import rpui.view.attributes;
import rpui.events;
import rpui.widgets.dialog;

import math.linalg;
import std.stdio;
import std.container;

import derelict.sfml2.graphics;
import derelict.opengl.gl;

class MyView : View {
    @ViewWidget Button okButton;
    @ViewWidget Panel testPanel;
    @ViewWidget("cancelButton") Button myButton;
    @ViewWidget Dialog testDialog;
    @GroupViewWidgets Button[3] buttons;

    int a = 0;

    this(Manager manager, in string laytoutFileName, in string shortcutsFileName) {
        super(manager, laytoutFileName, shortcutsFileName);
        // testPanel.freezeUI(false);

        okButton.events.subscribe!KeyPressedEvent(delegate(in event) {
            import std.stdio;
            writeln("Hello world! ", event.key);
        });
    }

    @OnClickListener("openDialogButton")
    void onOpenDialogButtonClick() {
        testDialog.open();
    }

    @OnClickListener("closeDialogButton")
    void onCloseDialogButtonClick() {
        testDialog.close();
    }

    @OnClickListener("okButton")
    void onOkButtonClick() {
        writeln("Hello world! a = ", a);
        a += 1;
        okButton.caption = "YAY!";
        myButton.caption = "WORKS!";
        buttons[2].caption = "YES!";
        // okButton.triggerEvent!("DblClick");
    }

    // @OnDblClickListener("okButton")
    // void onOkDblClick(Widget widget) {
    //     writeln("Double!");
    // }

    @OnMouseWheelListener("testPanel")
    void onTestPanelMouseWheel(in MouseWheelEvent event) {
        writeln("dx: ", event.dx, " dy: ", event.dy);
    }

    @Shortcut("TestGroup.cancel")
    void someShortcutAction() {
        writeln("Wow! shortcut was executed!");
    }

    @OnClickListener("closeButton")
    @OnClickListener("cancelButton")
    void onCancelButtonClick() {
        writeln("Close!");
    }
}


final class MapEditor: Application {
    mixin Singleton!MapEditor;

    private this() {
        super();
    }

    override void onProgress() {
        uiManager.onProgress();
        camera.update();
        uiManager.theme.regularFont.update();
    }

    override void render() {
        onPreRender(camera);
        // camera.

        // Texture texture = font.getTexture(text.textSize);

        // texture.bind();
        // glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	// glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

        shader.bind();
        shader.setUniformMatrix("MVP", sprite.lastMVPMatrix);
        shader.setUniformTexture("texture", texture);

        sprite.render(camera);
        // shader.setUniformTexture("texture", texture);

        sprite.rotate(0.01f);
        // sprite.move(0.0f, 1.0f);
        sprite.render(camera);

        // shader.setUniformMatrix("MVP", text.lastMVPMatrix);
        // shader.setUniformTexture("texture", font.getTexture(text.textSize));
        // text.render(camera);
        // camera.zoom += 0.01f;

        uiManager.render(camera);
        onPostRender(camera);

        // writeln(__traits(compiles, __traits(getMember, View, "layoutData")));
    }

    Camera camera;
    Geometry spriteGeometry;
    BaseObject sprite;
    Shader shader;
    Texture texture;
    Manager uiManager;
    Button testButton;
    MyView view;

    override void onCreate() {
        camera = new Camera(viewportWidth, viewportHeight);

        spriteGeometry = GeometryFactory.createSprite(false, true);
        sprite = new BaseObject(spriteGeometry);
        shader = new Shader(resourcesDirectory ~ "/shaders/GL2/transform.glsl");
        texture = new Texture(resourcesDirectory ~ "/test.jpg");

        camera.position = vec2(0.0f, 0.0f);
        camera.zoom = 1.0f;

        sprite.position = vec2(200.0f, 100.0f);
        sprite.scaling = vec2(200.0f, 200.0f);
        sprite.rotation = 0.5f;

        // shader.bind();
        // texture.bind();
        // spriteGeometry.bind();

        uiManager = new Manager(settings.theme);
        uiManager.stringsRes = StringsRes.createForLanguage(pathes, settings.language);
        uiManager.stringsRes.addStrings("test_view.rdl");
        uiManager.iconsRes.addIcons("icons", "icons.rdl");
        uiManager.iconsRes.addIcons("main toolbar icons", "main_toolbar_icons.rdl");

        events.join(uiManager.events);
        events.subscribe(uiManager);

        view = View.createFromFile!MyView(uiManager, "test.rdl");
    }

    override void onKeyReleased(in KeyCode key) {
        view.shortcuts.onKeyReleased(key);
        super.onKeyReleased(key);
    }

    override void onResize(in uint width, in uint height) {
        super.onResize(width, height);

        camera.viewportWidth  = viewportWidth;
        camera.viewportHeight = viewportHeight;
    }
}

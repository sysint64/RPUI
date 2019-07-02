module main;

import std.stdio;
import std.path;
import std.file;
import core.memory;

import rpui.application;
import rpui.events;
import rpui.view;
import rpui.view_component;
import rpui.widget;
import rpui.widgets.button.widget;
import rpui.widgets.panel.widget;
import rpui.widgets.dialog.widget;

import gapi.vec;
import gapi.camera;
import gapi.geometry;
import gapi.geometry_quad;
import gapi.shader;
import gapi.texture;
import gapi.transform;
import gapi.shader_uniform;
import gapi.opengl;

void main() {
    auto app = new TestApplication();
    app.run();
}

final class MyViewComponent : ViewComponent {
    @bindWidget Button okButton;
    @bindWidget Panel testPanel;
    @bindWidget("cancelButton") Button myButton;
    @bindWidget Dialog testDialog;
    @bindGroupWidgets Button[3] buttons;

    int a = 0;

    this(View view, in string laytoutFileName, in string shortcutsFileName) {
        super(view, laytoutFileName, shortcutsFileName);
    }

    void onCreate() {
        okButton.events.subscribe!KeyPressedEvent(delegate(in event) {
            writeln("Handle OkButton Key Pressed Event", event.key);
        });
    }

    @onClickListener("okButton")
    void onOkButtonClick() {
        writeln("Hello world! a = ", a);
        a += 1;
    }

    @onClickListener("okButton")
    void onOkButtonClick2() {
        okButton.caption = "YAY!";
        myButton.caption = "WORKS!";
        buttons[2].caption = "YES!";
    }

    @shortcut("TestGroup.cancel")
    void someShortcutAction() {
        writeln("Wow! shortcut was executed!");
    }

    @onClickListener("closeButton")
    @onClickListener("cancelButton")
    void onCancelButtonClick() {
        writeln("Close!");
    }

    @onClickListener("testMenuItem")
    @onClickListener("testMenuItem2")
    @onClickListener("openDialogButton")
    void onOpenDialogButtonClick() {
        testDialog.open();
    }

    @onClickListener("closeDialogButton")
    void onCloseDialogButtonClick() {
        testDialog.close();
    }
}

final class TestApplication : Application {
    private CameraMatrices cameraMatrices;
    private OthroCameraTransform cameraTransform = {
        viewportSize: vec2(1024, 768),
        position: vec2(0, 0),
        zoom: 1f
    };

    struct Geometry {
        Buffer indicesBuffer;
        Buffer verticesBuffer;
        Buffer texCoordsBuffer;

        VAO vao;
    }

    private Geometry sprite;
    private Texture2D spriteTexture;
    private ShaderProgram transformShader;
    private Transform2D spriteTransform;
    private mat4 spriteModelMatrix;
    private mat4 spriteMVPMatrix;
    private View rootView;

    override void onProgress(in ProgressEvent event) {
        cameraTransform.viewportSize.x = windowData.viewportWidth;
        cameraTransform.viewportSize.y = windowData.viewportHeight;

        spriteTransform.position = vec2(
            cameraTransform.viewportSize.x / 2,
            cameraTransform.viewportSize.y / 2
        );
        spriteTransform.scaling = vec2(430.0f, 600.0f);
        spriteTransform.rotation += 0.25f * event.deltaTime;

        spriteModelMatrix = create2DModelMatrix(spriteTransform);
        cameraMatrices = createOrthoCameraMatrices(cameraTransform);
        spriteMVPMatrix = cameraMatrices.mvpMatrix * spriteModelMatrix;

        glViewport(0, 0, cast(int) cameraTransform.viewportSize.x, cast(int) cameraTransform.viewportSize.y);
        rootView.onProgress(event);
    }

    override void onRender() {
        bindShaderProgram(transformShader);
        setShaderProgramUniformMatrix(transformShader, "MVP", spriteMVPMatrix);
        setShaderProgramUniformTexture(transformShader, "texture", spriteTexture, 0);

        bindVAO(sprite.vao);
        bindIndices(sprite.indicesBuffer);
        renderIndexedGeometry(cast(uint) quadIndices.length, GL_TRIANGLE_STRIP);
        rootView.onRender(RenderEvent(windowData.viewportWidth, windowData.viewportHeight, cameraMatrices.mvpMatrix));
    }

    override void onCreate() {
        createSprite();
        createTexture();
        createShaders();

        auto viewResources = createViewResources("light");
        viewResources.strings.setLocale("en");
        viewResources.strings.addStrings("test_view.rdl");

        rootView = new View(windowData.window, "light", cursorManager, viewResources);
        events.join(rootView.events);
        events.subscribe(rootView);

        ViewComponent.createFromFile!(MyViewComponent)(rootView, "test.rdl");
    }

    override void onDestroy() {
        deleteBuffer(sprite.indicesBuffer);
        deleteBuffer(sprite.verticesBuffer);
        deleteBuffer(sprite.texCoordsBuffer);
        deleteTexture2D(spriteTexture);
        deleteShaderProgram(transformShader);
    }

    override void onWindowResize(in WindowResizeEvent event) {
        super.onWindowResize(event);

        cameraTransform.viewportSize.x = event.width;
        cameraTransform.viewportSize.y = event.height;
    }

    private void createSprite() {
        sprite.indicesBuffer = createIndicesBuffer(quadIndices);
        sprite.verticesBuffer = createVector2fBuffer(centeredQuadVertices);
        sprite.texCoordsBuffer = createVector2fBuffer(quadTexCoords);

        sprite.vao = createVAO();
        bindVAO(sprite.vao);
        createVector2fVAO(sprite.verticesBuffer, inAttrPosition);
        createVector2fVAO(sprite.texCoordsBuffer, inAttrTextCoords);
    }

    private void createTexture() {
        const Texture2DParameters params = {
            minFilter: true,
            magFilter: true
        };
        spriteTexture = createTexture2DFromFile(buildPath("res", "test.jpg"), params);
    }

    private void createShaders() {
        const vertexSource = readText(buildPath("res", "shaders", "transform_vertex.glsl"));
        const vertexShader = createShader("transform vertex shader", ShaderType.vertex, vertexSource);

        const fragmentSource = readText(buildPath("res", "shaders", "texture_fragment.glsl"));
        const fragmentShader = createShader("transform fragment shader", ShaderType.fragment, fragmentSource);

        transformShader = createShaderProgram("transform program", [vertexShader, fragmentShader]);
    }
}

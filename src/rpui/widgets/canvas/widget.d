module rpui.widgets.canvas.widget;

import rpui.primitives;
import rpui.events;
import rpui.widget;

interface CanvasRenderer {
    void onCreate(Widget widget);

    void onDestroy();

    void onRender();

    void onProgress(in ProgressEvent event);
}

final class Canvas : Widget {
    enum Background {
        transparent,  /// Render without color.
        light,
        dark,
        action  /// Color for actions like OK, Cancel etc.
    }

    @field Background background = Background.light;  /// Background color of panel.

    private CanvasRenderer canvasRenderer_;
    private bool isInit = false;

    @property CanvasRenderer canvasRenderer() { return canvasRenderer_; }
    @property void canvasRenderer(CanvasRenderer val) {
        canvasRenderer_ = val;

        if (canvasRenderer_ && isInit) {
            canvasRenderer_.onCreate(this);
        }
    }

    ~this() {
        if (canvasRenderer_) {
            canvasRenderer_.onDestroy();
        }
    }

    override void onRender() {
        if (canvasRenderer_) {
            view.pushScissor(Rect(absolutePosition, size));
            canvasRenderer_.onRender();
            view.popScissor();
        }
    }

    override void onProgress(in ProgressEvent event) {
        super.onProgress(event);

        if (canvasRenderer_) {
            canvasRenderer_.onProgress(event);
        }
    }

    override void onCreate() {
        super.onCreate();

        if (canvasRenderer_) {
            canvasRenderer_.onCreate(this);
        }

        isInit = true;
    }
}

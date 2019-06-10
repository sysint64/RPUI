module rpui.resources.images;

import std.path;
import gapi.texture;
import rpui.paths;

/**
 * Get textures from files.
 */
final class ImagesRes {
    const Paths paths;
    private Texture2D[string] textures;
    private string uiTheme;

    this(in string uiTheme = "") {
        this.paths = createPathes();
        this.uiTheme = uiTheme;
    }

    ~this() {
        foreach (Texture2D texture; textures) {
            deleteTexture2D(texture);
        }
    }

    /**
     * Method loads the texture from `fileName` relative to $(I res/images).
     */
    Texture2D getTexture(in string fileName) {
        const key = "res:" ~ fileName;

        if (key !in textures) {
            const path = buildPath(paths.resources, "images", fileName);
            textures[key] = createTexture2DFromFile(path);
        }

        return textures[key];
    }

    /**
     * Method loads the texture from `fileName` for current UI theme
     * i.e. relative to $(I res/ui/themes/images/{theme name}/images).
     */
    Texture2D getTextureForUiTheme(in string fileName) {
        debug assert(uiTheme != "");
        const key = "ui:" ~ fileName;

        if (key !in textures) {
            const path = buildPath(paths.resources, "ui", "themes",
                                   uiTheme, "images", fileName);

            textures[key] = createTexture2DFromFile(path);
        }

        return textures[key];
    }

    /**
     * Method loads the texture from `fileName` which is absolute path.
     */
    Texture2D getTextureFromAbsolutePath(in string fileName) {
        const key = "absolute:" ~ fileName;

        if (fileName !in textures) {
            textures[key] = createTexture2DFromFile(fileName);
        }

        return textures[key];
    }
}

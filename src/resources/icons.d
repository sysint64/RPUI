/**
 * Copyright: © 2017 RedGoosePaws
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 * Authors: Andrey Kabylin
 */

module resources.icons;

import std.path;

import application;
import math.linalg;
import gapi.texture;

import resources.images;

import rpdl.tree;
import math.linalg;

struct Icon {
    string group;
    string name;
    Texture.Coord texCoord;
}

struct IconsConfig {
    string name;
    string textureFileName;
    bool themed;  /// If themed, then icon texture must placed in theme resources folder.
    vec2 size;  /// Size of one icon.
    vec2 start;  /// Start offset of all icons.
    vec2 gaps;  /// Spasing beetwen icons.
}

/**
 * This class uses RPDL files for icons repository, for each icons have group
 * where declared default config such as size of icon, gaps etc.
 */
class IconsRes {
    /**
     * Create icons resources, this constructor get `imagesRes` as argument
     * for getting textures for icons.
     */
    this(ImagesRes imagesRes) {
        assert(imagesRes !is null);
        this.imagesRes = imagesRes;
        this.app = Application.getInstance();
    }

    /// Get texture instance for particular group icons.
    Texture getTextureForIcons(in string group) {
        const config = iconsConfig[group];

        if (config.themed) {
            return this.imagesRes.getTextureForUiTheme(buildPath("icons", config.textureFileName));
        } else {
            return this.imagesRes.getTexture(buildPath("icons", config.textureFileName));
        }
    }

    /// Retrieve icon information from group by icon name.
    Icon getIcon(in string group, in string name) {
        auto texCoord = Texture.Coord();

        const config = iconsConfig[group];

        // Minus vec2(1, 1) due to icons indexing starting from 1
        const iconIndexes = iconsData[group].data.getVec2f("Icons." ~ name) - vec2(1, 1);
        const offsetWithGaps = vec2(
            iconIndexes.x * (config.size.x + config.gaps.x),
            iconIndexes.y * (config.size.y + config.gaps.y)
        );

        texCoord.offset = config.start + offsetWithGaps;
        texCoord.size = config.size;
        texCoord.normalize(getTextureForIcons(group));

        return Icon(group, name, texCoord);
    }

    /**
     * Add new icons group, file with icons declarations must placed in
     * res/ui/icons folder.
     */
    void addIcons(in string group, in string fileName) {
        const path = buildPath(app.resourcesDirectory, "ui", "icons");
        iconsData[group] = new RPDLTree(path);
        iconsData[group].load(fileName);
        iconsConfig[group] = IconsConfig();

        with (iconsConfig[group]) {
            auto groupData = iconsData[group].data;

            name = group;
            textureFileName = groupData.getString("Config.icons.0");
            themed = groupData.optBoolean("Config.themed.0", false);
            size = groupData.getVec2f("Config.size");
            start = groupData.getVec2f("Config.start");
            gaps = groupData.getVec2f("Config.gaps");
        }
    }

private:
    Application app;
    ImagesRes imagesRes;
    RPDLTree[string] iconsData;
    IconsConfig[string] iconsConfig;
}


unittest {
    import test.core;
    import dunit.assertion;

    initApp();

    auto imagesRes = new ImagesRes("light");
    auto iconsRes = new IconsRes(imagesRes);

    iconsRes.addIcons("icons", "icons.rdl");
    iconsRes.addIcons("main toolbar icons", "main_toolbar_icons.rdl");

// icons.rdl ---------------------------------------------------------------------------------------

    const folder = iconsRes.getIcon("icons", "folder");

    assertEquals("icons", folder.group);
    assertEquals("folder", folder.name);

    with (folder.texCoord) {
        assertEquals(18, size.x);
        assertEquals(18, size.y);
        assertEquals(30, offset.x);
        assertEquals(9, offset.y);
    }

    const material = iconsRes.getIcon("icons", "material");

    with (material.texCoord) {
        assertEquals(72, offset.x);
        assertEquals(72, offset.y);
    }

    const info = iconsRes.getIcon("icons", "info");

    with (info.texCoord) {
        assertEquals(114, offset.x);
        assertEquals(30, offset.y);
    }

// main_toolbar_icons.rdl --------------------------------------------------------------------------

    const wave = iconsRes.getIcon("main toolbar icons", "wave");

    with (wave.texCoord) {
        assertEquals(48, size.x);
        assertEquals(48, size.y);
        assertEquals(148, offset.x);
        assertEquals(50, offset.y);
    }

    const arc = iconsRes.getIcon("main toolbar icons", "arc");

    with (arc.texCoord) {
        assertEquals(50, offset.x);
        assertEquals(99, offset.y);
    }
}

/**
 * Copyright: © 2017 RedGoosePaws
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 */

module resources.icons;

import std.path;

import math.linalg;
import gapi.texture;

import resources.images;

import rpdl.tree;
import math.linalg;
import path;

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
    vec2 gaps;  /// Spacing beetwen icons.
}

/**
 * This class uses RPDL files for icons repository, for each icons have group
 * where declared default config such as size of icon, gaps etc.
 */
class IconsRes {
    const Pathes pathes;

    /**
     * Create icons resources, this constructor get `imagesRes` as argument
     * for getting textures for icons.
     */
    this(in Pathes pathes, ImagesRes imagesRes) {
        assert(imagesRes !is null);
        this.imagesRes = imagesRes;
        this.pathes = pathes;
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

    /// Get texture instance for particular icon.
    Texture getTextureForIcons(in Icon icon) {
        return getTextureForIcons(icon.group);
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

    /// Retrieve icon config from group.
    IconsConfig getIconsConfig(in string group) {
        return iconsConfig[group];
    }

    /**
     * Add new icons group, file with icons declarations must placed in
     * res/ui/icons folder.
     */
    void addIcons(in string group, in string fileName) {
        const path = buildPath(pathes.resources, "ui", "icons");
        iconsData[group] = new RpdlTree(path);
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
    ImagesRes imagesRes;
    RpdlTree[string] iconsData;
    IconsConfig[string] iconsConfig;
}

version(unittest) {
    import unit_threaded;

    IconsRes iconsRes;

    private void setUp() {
        // TODO: encapsulate
        import derelict.sfml2.graphics;
        DerelictSFML2Graphics.load();

        const pathes = initPathes();
        auto imagesRes = new ImagesRes(pathes, "light");
        iconsRes = new IconsRes(pathes, imagesRes);

        iconsRes.addIcons("icons", "icons.rdl");
        iconsRes.addIcons("main toolbar icons", "main_toolbar_icons.rdl");
    }
}

@("Should have correct icons bounds for icons.rdl")
unittest {
    setUp();

    const folder = iconsRes.getIcon("icons", "folder");

    folder.group.shouldEqual("icons");
    folder.name.shouldEqual("folder");

    with (folder.texCoord) {
        size.x.shouldEqual(18);
        size.y.shouldEqual(18);
        offset.x.shouldEqual(30);
        offset.y.shouldEqual(9);
    }

    const material = iconsRes.getIcon("icons", "material");

    with (material.texCoord) {
        offset.x.shouldEqual(72);
        offset.y.shouldEqual(72);
    }

    const info = iconsRes.getIcon("icons", "info");

    with (info.texCoord) {
        offset.x.shouldEqual(114);
        offset.y.shouldEqual(30);
    }
}

@("Should have correct bounds for main_toolbar_icons.rdl")
unittest {
    setUp();

    const wave = iconsRes.getIcon("main toolbar icons", "wave");

    with (wave.texCoord) {
        size.x.shouldEqual(48);
        size.y.shouldEqual(48);
        offset.x.shouldEqual(148);
        offset.y.shouldEqual(50);
    }

    const arc = iconsRes.getIcon("main toolbar icons", "arc");

    with (arc.texCoord) {
        offset.x.shouldEqual(50);
        offset.y.shouldEqual(99);
    }
}

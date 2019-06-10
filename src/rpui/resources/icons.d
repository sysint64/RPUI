module rpui.resources.icons;

import std.path;

import rpui.math;
import gapi.texture;

import rpui.resources.images;

import rpdl.tree;
import rpui.math;
import rpui.paths;

struct Icon {
    string group;
    string name;
    Texture2DCoords texCoord;
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
final class IconsRes {
    const Paths paths;

    /**
     * Create icons resources, this constructor get `imagesRes` as argument
     * for getting textures for icons.
     */
    this(ImagesRes imagesRes) {
        assert(imagesRes !is null);
        this.imagesRes = imagesRes;
        this.paths = createPathes();
    }

    /// Get texture instance for particular group icons.
    Texture2D getTextureForIcons(in string group) {
        const config = iconsConfig[group];

        if (config.themed) {
            return this.imagesRes.getTextureForUiTheme(buildPath("icons", config.textureFileName));
        } else {
            return this.imagesRes.getTexture(buildPath("icons", config.textureFileName));
        }
    }

    /// Get texture instance for particular icon.
    Texture2D getTextureForIcons(in Icon icon) {
        return getTextureForIcons(icon.group);
    }

    /// Retrieve icon information from group by icon name.
    Icon getIcon(in string group, in string name) {
        auto texCoord = Texture2DCoords();

        const config = iconsConfig[group];

        // Minus vec2(1, 1) due to icons indexing starting from 1
        const iconIndexes = iconsData[group].data.getVec2f("Icons." ~ name) - vec2(1, 1);
        const offsetWithGaps = vec2(
            iconIndexes.x * (config.size.x + config.gaps.x),
            iconIndexes.y * (config.size.y + config.gaps.y)
        );

        texCoord.offset = config.start + offsetWithGaps;
        texCoord.size = config.size;
        texCoord = normilizeTexture2DCoords(texCoord, getTextureForIcons(group));

        return Icon(group, name, texCoord);
    }

    /// Retrieve icon config from group.
    IconsConfig getIconsConfig(in string group) {
        assert(group in iconsConfig, "Unknown icons group '" ~ group ~ "'");
        return iconsConfig[group];
    }

    /**
     * Add new icons group, file with icons declarations must placed in
     * res/ui/icons folder.
     */
    void addIcons(in string group, in string fileName) {
        const path = buildPath(paths.resources, "ui", "icons");
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

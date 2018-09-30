module rpui.widget_locator;

import std.math;

import basic_types;
import math.linalg;

import rpui.widget;

package final class WidgetLocator {
    private Widget holder;

    this(Widget widget) {
        this.holder = widget;
    }

    void updateAbsolutePosition() {
        with (holder) {
            vec2 res = vec2(0, 0);
            Widget lastParent = parent;

            while (lastParent !is null) {
                res += lastParent.position - lastParent.contentOffset;
                res += lastParent.innerOffsetStart + lastParent.outerOffsetStart;
                lastParent = lastParent.parent;
            }

            absolutePosition = position + res + outerOffsetStart;
            absolutePosition.x = round(absolutePosition.x);
            absolutePosition.y = round(absolutePosition.y);
        }
    }

    void updateLocationAlign() {
        with (holder) {
            switch (locationAlign) {
                case Align.left:
                    position.x = 0;
                    break;

                case Align.right:
                    position.x = parent.innerBoundarySizeClamped.x - size.x - outerOffsetSize.x;
                    break;

                case Align.center:
                    const halfSize = (parent.innerBoundarySizeClamped.x - size.x - outerOffsetSize.x) / 2;
                    position.x = round(halfSize);
                    break;

                default:
                    break;
            }
        }
    }

    void updateVerticalLocationAlign() {
        with (holder) {
            switch (verticalLocationAlign) {
                case VerticalAlign.top:
                    position.y = 0;
                    break;

                case VerticalAlign.bottom:
                    position.y = parent.innerBoundarySizeClamped.y - size.y - outerOffsetSize.y;
                    break;

                case VerticalAlign.middle:
                    const halfSize = (parent.innerBoundarySizeClamped.y - size.y - outerOffsetSize.y) / 2;
                    position.y = round(halfSize);
                    break;

                default:
                    break;
            }
        }
    }

    void updateRegionAlign() {
        with (holder) {
            if (regionAlign == RegionAlign.none)
                return;

            const FrameRect region = locator.findRegion();
            const vec2 regionSize = vec2(
                parent.innerSize.x - region.right  - region.left - outerOffsetSize.x,
                parent.innerSize.y - region.bottom - region.top  - outerOffsetSize.y
            );

            const vec2 fullRegionSize = vec2(
                parent.size.x - region.right  - region.left - outerOffsetSize.x,
                parent.size.y - region.bottom - region.top  - outerOffsetSize.y
            );

            outerBoundarySize = size;

            switch (regionAlign) {
                case RegionAlign.client:
                    size = regionSize;
                    outerBoundarySize = fullRegionSize;
                    position = vec2(region.left, region.top);
                    break;

                case RegionAlign.top:
                    size.x = regionSize.x;
                    outerBoundarySize.x = fullRegionSize.x;
                    position = vec2(region.left, region.top);
                    break;

                case RegionAlign.bottom:
                    size.x = regionSize.x;
                    outerBoundarySize.x = fullRegionSize.x;
                    position.x = region.left;
                    position.y = parent.innerSize.y - outerSize.y - region.bottom;
                    break;

                case RegionAlign.left:
                    size.y = regionSize.y;
                    outerBoundarySize.y = fullRegionSize.y;
                    position = vec2(region.left, region.top);
                    break;

                case RegionAlign.right:
                    size.y = regionSize.y;
                    outerBoundarySize.y = fullRegionSize.y;
                    position.x = parent.innerSize.x - outerSize.x - region.right;
                    position.y = region.top;
                    break;

                default:
                    break;
            }
        }
    }

    FrameRect findRegion() {
        FrameRect region;

        foreach (Widget widget; holder.parent.children) {
            if (widget == holder)
                break;

            if (!widget.visible || widget.regionAlign == RegionAlign.none)
                continue;

            switch (widget.regionAlign) {
                case RegionAlign.top:
                    region.top += widget.size.y + widget.outerOffset.bottom;
                    break;

                case RegionAlign.left:
                    region.left += widget.size.x + widget.outerOffset.right;
                    break;

                case RegionAlign.bottom:
                    region.bottom += widget.size.y + widget.outerOffset.top;
                    break;

                case RegionAlign.right:
                    region.right += widget.size.x + widget.outerOffset.left;
                    break;

                default:
                    continue;
            }
        }

        return region;
    }
}

module rpui.widgets.text_input.edit_component;

import input;
import basic_types;
import math.linalg;
import std.algorithm.comparison;
import std.algorithm.searching;

import rpui.widgets.text_input;
import rpui.widgets.text_input.select_component;
import rpui.widgets.text_input.carriage;
import rpui.widgets.text_input.render_data;
import rpui.render_objects;
import rpui.render_factory;
import rpui.renderer;
import rpui.events;
import rpui.theme;

struct EditComponent {
    const commonSplitChars = " ,.;:?'!|/\\~*+-=(){}<>[]#%&^@$№`\""d;
    const japanesePunctuation = "\u3000｛｝（）［］【】、，…‥。〽「」『』〝〟〜：！？"d;
    const splitChars = commonSplitChars ~ japanesePunctuation;

    utfstring text;
    Carriage carriage;
    float scrollDelta = 0.0f;
    vec2 absoulteTextPosition;

    SelectRegion selectRegion;
    RenderData renderData;

    void reset() {
        selectRegion.stopSelection();
        carriage.reset();
    }

    void onKeyPressed(in KeyPressedEvent event) {
        carriage.timer = 0;
        carriage.visible = true;

        if (isKeyPressed(KeyCode.Shift) && !selectRegion.startedSelection)
            selectRegion.startSelection(carriage.pos);

        switch (event.key) {
            case KeyCode.Left:
                if (isKeyPressed(KeyCode.Ctrl)) {
                    carriage.setCarriagePos(carriage.navigateCarriage(-1));
                } else {
                    carriage.moveCarriage(-1);
                }

                break;

            case KeyCode.Right:
                if (isKeyPressed(KeyCode.Ctrl)) {
                    carriage.setCarriagePos(carriage.navigateCarriage(1));
                } else {
                    carriage.moveCarriage(1);
                }

                break;

            case KeyCode.Home:
                carriage.setCarriagePos(0);
                break;

            case KeyCode.End:
                carriage.setCarriagePos(cast(int) text.length);
                break;

            case KeyCode.Delete:
                if (selectRegion.textIsSelected()) {
                    removeSelectedRegion();
                } else {
                    if (isKeyPressed(KeyCode.Ctrl)) {
                        const end = carriage.navigateCarriage(1);
                        removeRegion(carriage.pos, end);
                    } else {
                        removeRegion(carriage.pos, carriage.pos+1);
                    }
                }
                break;

            case KeyCode.Back:
                if (selectRegion.textIsSelected()) {
                    removeSelectedRegion();
                } else {
                    if (isKeyPressed(KeyCode.Ctrl)) {
                        const start = carriage.navigateCarriage(-1);
                        removeRegion(start, carriage.pos);
                    } else {
                        removeRegion(carriage.pos-1, carriage.pos);
                    }
                }
                break;

            default:
                // Nothing
        }
    }

    void removeSelectedRegion() {
        removeRegion(
            selectRegion.start,
            selectRegion.end
        );
    }

    void removeRegion(in int start, in int end) {
        if (start < 0 || end > text.length)
            return;

        const leftPart = text[0 .. start];
        const rightPart = text[end .. text.length];

        text = leftPart ~ rightPart;
        carriage.setCarriagePos(start);
    }

    private bool isCharAllowed(in utfchar ch) {
        const b1 = ch;
        const b2 = ch >> 8;

        // TODO: why? link!
        return (b2 != 0 || b1 >= 0x20) && b1 <= 0x7E;
    }

    bool onTextEntered(in TextEnteredEvent event) {
        carriage.timer = 0;
        carriage.visible = true;

        const charToPut = event.key;

        if (!isCharAllowed(charToPut))
            return false;

        // Splitting text to two parts by carriage position

        utfstring leftPart;
        utfstring rightPart;

        if (!selectRegion.textIsSelected()) {
            leftPart = text[0 .. carriage.pos];
            rightPart = text[carriage.pos .. $];
            carriage.pos++;
        }
        else {
            leftPart = text[0 .. selectRegion.start];
            rightPart = text[selectRegion.end .. $];
            carriage.pos = selectRegion.start + 1;
        }

        text = leftPart ~ charToPut ~ rightPart;
        selectRegion.stopSelection();

        return true;
    }

    void onMouseDown(in MouseDownEvent event) {
         carriage.setCarriagePosFromMousePos(event.x, event.y);
    }

    float getTextWidth() {
        return renderData.textRenderObject.textWidth;
    }

    // TODO: dmd PR #8155
    float getTextRegionSize(in int start, in int end)
    in {
        assert(start <= end);
    }
    do {
        if (start == end)
            return 0.0f;

        return cast(float) renderData.textRenderObject.getRegionTextWidth(start, end);
    }

    vec2 getTextRegionOffset(in int charPos) {
        const regionSize = getTextRegionSize(0, charPos);
        const offset = vec2(
            regionSize + scrollDelta,
            -cast(float)(renderData.textRenderObject.lineHeight) + renderData.textTopMargin
        );

        float alignOffset = 0;

        if (renderData.textRenderObject.textAlign == Align.left) {
            alignOffset = renderData.textLeftMargin;
        }
        else if (renderData.textRenderObject.textAlign == Align.right) {
            alignOffset = -renderData.textRightMargin;
        }

        return vec2(alignOffset - renderData.carriageBoundary, 0) +
            renderData.textRenderObject.getTextRelativePosition() + offset;
    }
}

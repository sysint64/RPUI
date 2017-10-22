module ui.shortcuts;

import std.stdio;
import std.string;
import std.conv;
import std.path;

import rpdl;
import rpdl.exception;
import input;
import application;
import ui.widget;


class Shortcuts {
    struct Shortcut {
        bool shift;
        bool ctrl;
        bool alt;
        KeyCode key;

        this(bool shift, bool ctrl, bool alt, KeyCode key) {
            this.shift = shift;
            this.ctrl = ctrl;
            this.alt = alt;
            this.key = key;
        }

        void readKey(in string key) {
            switch (key) {
                case "Ctrl":
                    this.ctrl = true;
                    break;

                case "Shift":
                    this.shift = true;
                    break;

                case "Alt":
                    this.alt = true;
                    break;

                default:
                    this.key = to!KeyCode(key);
            }
        }

        this(in string shortcut) {
            foreach (string key; shortcut.split("+"))
                readKey(key);
        }
    }

    struct ShortcutAction {
        enum Type { simpleWidgetListener, simpleFunction };

        Shortcut[] shortcuts;  // Composite e.g. Ctrl+X Ctrl+S

        this(in string shortcutString) {
            foreach (shortcut; shortcutString.split(" ")) {
                shortcuts ~= Shortcut(shortcut);
            }
        }

        this(in string shortcutString, void delegate() action) {
            foreach (shortcut; shortcutString.split(" ")) {
                shortcuts ~= Shortcut(shortcut);
            }

            this.action = action;
        }

        void delegate() action;
    }

    this(in string fileName) {
        shortcutsData = new RPDLTree(dirName(fileName));
        shortcutsData.load(baseName(fileName), RPDLTree.IOType.text);
    }

    static createFromFile(in string fileName) {
        auto app = Application.getInstance();
        const string path = buildPath(app.resourcesDirectory, "ui", "shortcuts", fileName);
        return new Shortcuts(path);
    }

    void onKeyReleased(in KeyCode key) {
        foreach (ShortcutAction shortcut; shortcuts) {
            if (doShortcut(shortcut))
                return;
        }
    }

    void attach(in string path, void delegate() action) {
        try {
            const string shortcut = shortcutsData.data.getString(path ~ ".0");
            auto shortcutAction = Shortcuts.ShortcutAction(shortcut, action);
            shortcuts[path] = shortcutAction;
        } catch (NotFoundException) {
            debug assert(false, "Not found shortcut with path " ~ path);
        }
    }

private:
    ShortcutAction[string] shortcuts;
    RPDLTree shortcutsData;

    bool doShortcut(ShortcutAction shortcutAction) {
        const Shortcut shortcut = shortcutAction.shortcuts[0];

        if (isKeyPressed(shortcut.key) &&
            testKeyState(KeyCode.Shift, shortcut.shift) &&
            testKeyState(KeyCode.Ctrl, shortcut.ctrl) &&
            testKeyState(KeyCode.Alt, shortcut.alt))
        {
            shortcutAction.action();
            return true;
        }

        return false;
    }
}

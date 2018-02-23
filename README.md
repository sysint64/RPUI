# RPUI
User Interface Library based on OpenGL

## Example of usage

**Layout**
```Yaml
Panel
    allowResize: true
    regionAlign: right
    align: center
    locationAlign: center
    size: 300, 0
    position: 100, 0
    finalFocusRegion: true
    blackSplit: true
    finalFocus: true

    Panel
        name: "testPanel"
        caption: "@TestView.mainPanelCaption"
        allowHide: true
        regionAlign: top
        background: light
        position: 0, 0
        size: 0, 100.5
        padding: 5

        Button
            position: 100, 5
            size: 200, 21
            caption: "String: @TestView.helloWorld"
            name: "okButton"
            locationAlign: center
            verticalLocationAlign: middle
            margin: 5

        Panel
            size: 150, 50
            position: 5, 31
            background: dark
            margin: 10
            Button position: 0, 0 size: 100, 21 caption: "Cancel" name: "cancelButton"
            Button position: 5, 57 size: 100, 21 caption: "Close" name: "closeButton"

    Panel
        regionAlign: top
        background: light
        position: 0, 0
        size: 0, 300
        caption: "Panel 2"
        allowResize: true
        allowHide: true
        padding: 0, 100, 0, 0

        StackLayout
            name: "buttons"

            Button size: 100, 21 margin: 5 caption: "Button 1"
            Button size: 100, 21 margin: 5 caption: "Button 2"
            Button size: 100, 21 margin: 5 caption: "Button 3"

Panel
    background: dark
    regionAlign: client

    Panel
        regionAlign: right
        size: 300, 300
        blackSplit: true
        margin: 5

        StackLayout
            name: "buttons"
            orientation: horizontal

            Button size: 100, 21 margin: 5 caption: "Button 1"
            Button size: 100, 21 margin: 5 caption: "Button 2"
            Button size: 100, 21 margin: 5 caption: "Button 3"

    Panel
        regionAlign: left
        size: 300, 300
        blackSplit: true
        margin: 5
```

**Strings for ru**
```Yaml
TestView
    mainPanelCaption: "Это главная панель"
    helloWorld: "Привет мир!"
```

**Strings for en**
```Yaml
TestView
    mainPanelCaption: "This is main panel"
    helloWorld: "Hello World!"
```

**Shorcuts**
```Yaml
General
    focusNext: "Tab"
    focusPrev: "Shift+Tab"
    submit: "Ctrl+Return"

TestGroup
    cancel: "Ctrl+C"
```

**View**
```D
class MyView : View {
    @ViewWidget Button okButton;
    @ViewWidget Panel testPanel;
    @ViewWidget("cancelButton") Button myButton;
    @GroupViewWidgets Button[3] buttons;

    int a = 0;

    this(Manager manager, in string laytoutFileName, in string shortcutsFileName) {
        super(manager, laytoutFileName, shortcutsFileName);
    }

    @OnClickListener("okButton")
    void onOkButtonClick(Widget widget) {
        writeln("Hello world! a = ", a);
        a += 1;
        okButton.caption = "YAY!";
        myButton.caption = "WORKS!";
        buttons[2].caption = "YES!";
    }

    @Shortcut("TestGroup.cancel")
    void someShortcutAction() {
        writeln("Wow! shortcut was executed!");
    }

    @OnClickListener("closeButton")
    @OnClickListener("cancelButton")
    void onCancelButtonClick(Widget widget) {
        writeln("Close!");
    }
}
```

**Resuls**
![Image](https://raw.githubusercontent.com/sysint64/RPUI/master/readme_screenshot.png)

## Documentation
WIP

## Dependencies

- ftgl
- csfml

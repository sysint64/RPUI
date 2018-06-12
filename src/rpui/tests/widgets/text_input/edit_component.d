module rpui.tests.widgets.text_input.edit_component;

version(unittest) {
    import unit_threaded;
    import rpui.widgets.text_input.edit_component;
}

@("navigateCarriage backward 1")
unittest {
    auto editComponent = EditComponent();
    editComponent.text = "Hello wordl!";
    //                    | ^
    editComponent.carriage.pos = 2;
    const pos = editComponent.navigateCarriage(-1);
    pos.shouldEqual(0);
}

@("navigateCarriage forward 1")
unittest {
    auto editComponent = EditComponent();
    editComponent.text = "Hello wordl!";
    //                      ^  |
    editComponent.carriage.pos = 2;
    const pos = editComponent.navigateCarriage(1);
    pos.shouldEqual(5);
}

@("navigateCarriage backward 2")
unittest {
    auto editComponent = EditComponent();
    editComponent.text = "Hello wordl!";
    //                          | ^
    editComponent.carriage.pos = 8;
    const pos = editComponent.navigateCarriage(-1);
    pos.shouldEqual(6);
}

@("navigateCarriage forward 2")
unittest {
    auto editComponent = EditComponent();
    editComponent.text = "Hello wordl! Test(*)";
    //                           ^   |
    editComponent.carriage.pos = 7;
    const pos = editComponent.navigateCarriage(1);
    pos.shouldEqual(11);
}

@("navigateCarriage backward 3")
unittest {
    auto editComponent = EditComponent();
    editComponent.text = "Hello (%@)wordl! Test(*)";
    //                              | ^
    editComponent.carriage.pos = 12;
    const pos = editComponent.navigateCarriage(-1);
    pos.shouldEqual(10);
}

@("navigateCarriage forward 3")
unittest {
    auto editComponent = EditComponent();
    editComponent.text = "Hello (%@)wordl! Test(*)";
    //                                ^  |
    editComponent.carriage.pos = 12;
    const pos = editComponent.navigateCarriage(1);
    pos.shouldEqual(15);
}

@("navigateCarriage backward 4")
unittest {
    auto editComponent = EditComponent();
    editComponent.text = "Hello (%@)wordl! Test(*)";
    //                    |         ^
    editComponent.carriage.pos = 10;
    const pos = editComponent.navigateCarriage(-1);
    pos.shouldEqual(0);
}

@("navigateCarriage forward 4")
unittest {
    auto editComponent = EditComponent();
    editComponent.text = "Hello (%@)wordl! Test(*)";
    //                            ^      |
    editComponent.carriage.pos = 8;
    const pos = editComponent.navigateCarriage(1);
    pos.shouldEqual(15);
}

@("navigateCarriage backward 5")
unittest {
    auto editComponent = EditComponent();
    editComponent.text = "Hello (....)wordl! Test(*)";
    //                    |         ^
    editComponent.carriage.pos = 10;
    const pos = editComponent.navigateCarriage(-1);
    pos.shouldEqual(0);
}

@("navigateCarriage forward 5")
unittest {
    auto editComponent = EditComponent();
    editComponent.text = "Hello (....)wordl! Test(*)";
    //                           ^         |
    editComponent.carriage.pos = 7;
    const pos = editComponent.navigateCarriage(1);
    pos.shouldEqual(17);
}

@("navigateCarriage backward 6")
unittest {
    auto editComponent = EditComponent();
    editComponent.text = "Hello (....)wordl! Test(*)";
    //                    ^
    editComponent.carriage.pos = 0;
    const pos = editComponent.navigateCarriage(-1);
    pos.shouldEqual(0);
}

@("navigateCarriage forward 6")
unittest {
    auto editComponent = EditComponent();
    editComponent.text = "Hello (....)wordl! Test(*)";
    //                                             ^
    editComponent.carriage.pos = 25;
    const pos = editComponent.navigateCarriage(1);
    pos.shouldEqual(26);
}

@("navigateCarriage backward 7")
unittest {
    auto editComponent = EditComponent();
    editComponent.text = "!Hello World";
    //                    |^
    editComponent.carriage.pos = 1;
    const pos = editComponent.navigateCarriage(-1);
    pos.shouldEqual(0);
}

@("navigateCarriage forward 7")
unittest {
    auto editComponent = EditComponent();
    editComponent.text = "Hello World!";
    //                              ^|
    editComponent.carriage.pos = 10;
    const pos = editComponent.navigateCarriage(1);
    pos.shouldEqual(12);
}

@("findPosUntilSeparator backward 1")
unittest {
    auto editComponent = EditComponent();
    editComponent.text = "Hello wordl!";
    //                    |  ^
    editComponent.carriage.pos = 2;
    const pos = editComponent.findPosUntilSeparator(-1);
    pos.shouldEqual(0);
}

@("findPosUntilSeparator forward 1")
unittest {
    auto editComponent = EditComponent();
    editComponent.text = "Hello wordl!";
    //                      ^  |
    editComponent.carriage.pos = 2;
    const pos = editComponent.findPosUntilSeparator(1);
    pos.shouldEqual(5);
}

@("findPosUntilSeparator backward 2")
unittest {
    auto editComponent = EditComponent();
    editComponent.text = "Hello wordl!";
    //                         |  ^
    editComponent.carriage.pos = 8;
    const pos = editComponent.findPosUntilSeparator(-1);
    pos.shouldEqual(5);
}

@("findPosUntilSeparator forward 2")
unittest {
    auto editComponent = EditComponent();
    editComponent.text = "Hello wordl! Test(*)";
    //                           ^   |
    editComponent.carriage.pos = 7;
    const pos = editComponent.findPosUntilSeparator(1);
    pos.shouldEqual(11);
}

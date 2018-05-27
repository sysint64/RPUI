module rpui.tests.widgets.text_input.edit_component;

version(unittest) {
    import unit_threaded;
    import rpui.widgets.text_input.edit_component;
}

@("navigateCarriage backward test 1")
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

@("navigateCarriage backward test 2")
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

@("navigateCarriage backward test 3")
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

@("navigateCarriage backward test 4")
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

@("navigateCarriage backward test 5")
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
    pos.shouldEqual(25);
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

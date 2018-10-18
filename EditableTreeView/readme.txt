EditableTreeView is a TreeView with TextFields to edit content right out of the view.

It provides the following functions to handle content and view:
- insertItem: insert item as child of the currently selected item (or as child of the root item if nothing is selected)
- getDataAsJson: get data of passed item as JSON array. If null is passed, you receive the complete data of the tree.

Press DELETE on your keyboard to delete selected item and children.
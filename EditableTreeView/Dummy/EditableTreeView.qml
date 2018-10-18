import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

Item {
	id: root;
	width: 600;
	height: 600;

	property var selectedItem: null;

	ListModel {
		id: rootItems;
	}
      
	ColumnLayout {
		id: rootLayout;
		anchors.fill: parent;

		ListView {
			id: listView;
			Layout.fillHeight: true;
			Layout.fillWidth: true;
			model: rootItems;
			delegate: itemDelegate;
		}
	}
	
	Component {
		id: itemDelegate;

		Column {
			id: delegateColumn;
			clip: true;

			Row {
				id: delegateRow;

				property bool expanded: true;
				property bool hasChildren:  delegateColumn.children.length > 2; // when there's more than 2 columns

				Item {
					id: spacer;
					height: 1;
					width: model.level * 50;
				}

				Button {
					id: expandButton;
					width: 15;
					height: 15;
					text:  parent.expanded ? qsTr("-   ") : qsTr("+   ");
					visible: parent.hasChildren;

					style: ButtonStyle {
						background: Rectangle {
							border.width: 0;
							border.color: "transparent";
						}
						label: Text {
							font { bold: true; pixelSize: 14 }
							text: control.text;
						}
					}

					onClicked: {
						parent.expanded = !parent.expanded;

						// hide children
						for(var i = 1; i < parent.parent.children.length - 1; ++i) {
							parent.parent.children[i].visible = !parent.parent.children[i].visible;
						}
					}
				}

				TextField {
					id: keyTextField;
					text: model.key;
					font { bold: parent.hasChildren; pixelSize: 14 }

					Keys.forwardTo: [root]; // forward key events to root

					style: TextFieldStyle {
						background: Rectangle {
							color: control.focus ? "#c6e1f8" : "white";
							border.width: 0;
						}
					}

					onEditingFinished: {
						// lose focus when editing is finished
						focus = false;
					}

					onFocusChanged: {
						// set selectedItem when item is selected and update ListModel when it looses focus
						if(focus) {
							selectedItem = model;
							selectAll();
						}
						else {	
							model.key = text;					
						}
					}
				}

				TextField {
					id: valueTextField;
					text: model.value;
					font { pixelSize: 14 }
					visible: model.value != "";

					Keys.forwardTo: [root]; // forward key events to root

					style: TextFieldStyle {
						background: Rectangle {
							color: control.focus ? "#c6e1f8" : "white";
							border.width: 0;
						}
					}

					onEditingFinished: {
						focus = false;
					}

					onFocusChanged: {
						if(focus) {
							selectedItem = model;
							selectAll();
						}
						else {	
							model.value = text;					
						}
					}
				}
			}

			Repeater {
				id: childrenRepeater;
				model: childNodes;
				delegate: itemDelegate;
			}
		}
	}
   
	Keys.onDeletePressed: {
		// delete selected item with children when DEL is pressed
		if(selectedItem !== null) {
			var parent = getParentNode(null, selectedItem);
			var children = (parent === null) ? rootItems : parent.childNodes;

			for(var i = 0; i < children.count; i++) {
				var child = children.get(i);
				if (child.key === selectedItem.key && child.value === selectedItem.value) {
					children.remove(i);

					// insert root item if it was deleted before
					if(rootItems.count === 0) {
						insertRootItem();
					}
				}
			}
		}
	}
   
	function insertRootItem() {
		rootItems.append({"key": "DATA", "value": "", "level": 0, "childNodes": []});
	}
	
	function insertItem() {
		// insert item as child of selected node or into rootItems when no item is selected
		if(selectedItem === null) {
			rootItems.get(0).childNodes.append({"key": "key", "value": "value", "level": rootItems.get(0).level+1, "childNodes": []});
		}
		else {
			selectedItem.childNodes.append({"key": "key", "value": "value", "level": selectedItem.level+1, "childNodes": []});
			selectedItem.value = ""; // clear value of parent item
		}
	}
   
	function getParentNode(parent, childNode) {
		// use rootItems when no parent is passed
		var itemList = (parent === null) ? rootItems : parent.childNodes;

		// iterate through items and children to find parent
		for(var i = 0; i < itemList.count; i++) {
			var item = itemList.get(i);			  
			if(item.key === childNode.key && item.value === childNode.value) {
				return parent;
			}
			else if(item.childNodes.count > 0) {
				return getParentNode(item, childNode);
			}
		}
		return null;
	}
   
	function getDataAsJson(item) {
		var dataArray = [];
		
		// use root item when item is null
		if(item === null) {
			item = rootItems.get(0);
		}

		for(var i = 0; i < item.childNodes.count; i++) {
			var child = item.childNodes.get(i);

			// append item with children to JSON array, if it has no children append item with key and value to array
			if (child.childNodes.count > 0) {
				var obj = JSON.parse('{"'+child.key+'": '+JSON.stringify(getDataAsJson(child))+'}'); // { "key" : [...] }
				dataArray.push(obj);
			}
			else {
				var obj = JSON.parse('{"'+child.key+'": "'+child.value+'"}'); // { "key" : "value" }
				dataArray.push(obj);
			}		   
		}
		return dataArray;
	}
      
	Component.onCompleted: {
		insertRootItem();
	}
}
import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4

Rectangle {
	id: root;
	width: 600;
	height: 800;
	color: "white";

	ColumnLayout {
		id: rootLayout;
		anchors.fill: parent;
		
		EditableTreeView {
			id: treeView;
			Layout.fillWidth: true;
			Layout.fillHeight: true;
		}
		
		RowLayout {
			id: buttonsLayout;
			Layout.fillWidth: true;
			height: 50;
			
			Button {
				id: addButton;
				text: "+" 
				height: 50;
				
				onClicked: {
					treeView.insertItem();
					
					forceActiveFocus(); // force focus to lose focus on treeView
				}
			}

			Button {
				text: "show JSON" 
				height: 50;
				
				onClicked: {
					var json = JSON.parse('{ "data": ' + JSON.stringify(treeView.getDataAsJson(null)) + '}'); // pass null to use root item
					output.text = JSON.stringify(json);

					forceActiveFocus(); // force focus to lose focus on treeView
				}
			}
		}
		
		TextField {
			id: output;
			Layout.fillWidth: true;
			Layout.preferredHeight: 200;
			readOnly: true;
		}
	}
}
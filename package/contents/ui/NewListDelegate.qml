import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

Item {
    id: item

    signal clicked
    property alias text: label.text
    height: row.height
    Layout.fillWidth: true

    RowLayout {
        id: row
        Layout.fillWidth: true
        PlasmaComponents.ToolButton {
            id: button
            implicitWidth: 200
            Layout.fillWidth: true
            Layout.fillHeight: true
            onClicked: {
                item.clicked()
            }

            contentItem: RowLayout {
                PlasmaComponents.Label {
                    id: label
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    //level: 4
                    text: subCategoryColumn.title
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    textFormat: Text.PlainText
                }
            }
        }
    }
}
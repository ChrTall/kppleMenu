// SPDX-License-Identifier: GPL-2.0-or-later
// Tree connectors and entry presentation are inspired by 51n7/kMenu's
// TreeItemDelegate.qml (GPL-2.0-or-later):
// https://github.com/51n7/kMenu/blob/915bfc9d809fe30a6502dc9fd7f4f4d7f140d8d4/package/contents/ui/config/TreeItemDelegate.qml
// Reimplemented for a flat menu with visibility checkboxes and Kirigami drag handles.
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

QQC2.ItemDelegate {
    id: root

    required property var entry
    required property int modelIndex
    required property int entryCount
    required property ListView view
    required property string labelText
    required property string kindText
    readonly property bool separator: entry.type === "separator"
    readonly property color lineColor: highlighted ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
    readonly property real branchX: leftPadding + branch.x + branch.width / 2

    signal visibilityEdited(bool shown)
    signal moveRequested(int oldIndex, int newIndex)
    signal reorderFinished()

    topPadding: 0
    bottomPadding: 0
    Accessible.name: labelText + ", " + kindText
    background: Rectangle {
        color: root.highlighted ? Kirigami.Theme.highlightColor
            : root.hovered ? Kirigami.Theme.alternateBackgroundColor : "transparent"
    }

    // The current menu has one level. The spine leaves room for future nesting.
    Rectangle {
        x: root.branchX
        y: root.modelIndex === 0 ? root.height / 2 : 0
        width: 1
        height: root.height - y - (root.modelIndex === root.entryCount - 1 ? root.height / 2 : 0)
        color: root.lineColor
        opacity: 0.35
    }

    Rectangle {
        x: root.branchX
        y: root.height / 2
        width: branch.width / 2
        height: 1
        color: root.lineColor
        opacity: 0.35
    }

    contentItem: RowLayout {
        spacing: Kirigami.Units.smallSpacing

        Kirigami.ListItemDragHandle {
            id: handle

            property int index: root.modelIndex

            listItem: root
            listView: root.view
            Accessible.name: i18n("Drag to reorder")
            onDragActiveChanged: {
                if (dragActive)
                    root.clicked();

            }
            onMoveRequested: (oldIndex, newIndex) => {
                return root.moveRequested(oldIndex, newIndex);
            }
            onDropped: (oldIndex, newIndex) => {
                if (oldIndex >= 0 && newIndex >= 0)
                    root.reorderFinished();

            }
            QQC2.ToolTip.visible: handleHover.hovered && !dragActive
            QQC2.ToolTip.text: i18n("Drag to reorder")
            QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay

            HoverHandler {
                id: handleHover
            }

        }

        QQC2.CheckBox {
            checked: root.entry.visible
            Accessible.name: i18n("Show %1", root.labelText)
            onClicked: root.visibilityEdited(checked)
        }

        Item {
            id: branch

            Layout.preferredWidth: Kirigami.Units.gridUnit
            Layout.preferredHeight: 1
        }

        Item {
            Layout.fillWidth: true
            implicitWidth: root.separator ? Kirigami.Units.gridUnit * 3 : nameLabel.implicitWidth
            implicitHeight: nameLabel.implicitHeight

            QQC2.Label {
                id: nameLabel

                anchors.fill: parent
                visible: !root.separator
                text: root.labelText
                textFormat: Text.PlainText
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
                color: root.lineColor
                opacity: root.entry.visible ? 1 : 0.5
            }

            Rectangle {
                visible: root.separator
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                height: 1
                color: root.lineColor
                opacity: root.entry.visible ? 0.4 : 0.2
            }

        }

        QQC2.Label {
            text: root.kindText
            color: root.lineColor
            opacity: 0.7
        }

    }

}

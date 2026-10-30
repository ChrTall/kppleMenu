import ".."
import "../code/menuLayout.js" as MenuLayout
// SPDX-License-Identifier: GPL-2.0-or-later
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: root

    property string layoutJson: ""
    property var builtinCommands: ({
    })
    property var commandDefaults: ({
    })
    readonly property var parsed: MenuLayout.parse(layoutJson)
    readonly property var entries: parsed.entries
    property string selectedId: ""
    readonly property int selectedIndex: entries.findIndex((entry) => {
        return entry.id === selectedId;
    })
    readonly property var selectedEntry: selectedIndex >= 0 ? entries[selectedIndex] : null
    readonly property string selectedCommandKey: selectedEntry && selectedEntry.type === "builtin" ? actions.action(selectedEntry.id).commandKey : ""
    readonly property string selectedCommand: selectedCommandKey ? String(builtinCommands[selectedCommandKey] || "") : selectedEntry && selectedEntry.type === "custom" ? selectedEntry.command : ""

    signal builtinCommandEdited(string key, string command)

    function setCommand(command) {
        if (selectedCommandKey)
            builtinCommandEdited(selectedCommandKey, command);
        else if (selectedEntry && selectedEntry.type === "custom")
            updateEntry(selectedId, "command", command);
    }

    function syncEntries() {
        if (!editModel)
            return ;

        for (let i = 0; i < entries.length; ++i) {
            const entry = entries[i];
            let previous = -1;
            for (let j = i; j < editModel.count; ++j) {
                if (editModel.get(j).entryId === entry.id) {
                    previous = j;
                    break;
                }
            }
            const row = {
                "entryId": entry.id,
                "entryType": entry.type,
                "entryVisible": entry.visible,
                "entryName": entry.name || "",
                "entryCommand": entry.command || ""
            };
            if (previous < 0) {
                editModel.insert(i, row);
            } else {
                if (previous !== i)
                    editModel.move(previous, i, 1);

                editModel.set(i, row);
            }
        }
        if (editModel.count > entries.length)
            editModel.remove(entries.length, editModel.count - entries.length);

    }

    function commitReorder() {
        const next = [];
        for (let i = 0; i < editModel.count; ++i) {
            const row = editModel.get(i);
            const entry = {
                "type": row.entryType,
                "id": row.entryId,
                "visible": row.entryVisible
            };
            if (entry.type === "custom") {
                entry.name = row.entryName;
                entry.command = row.entryCommand;
            }
            next.push(entry);
        }
        if (JSON.stringify(next) !== JSON.stringify(entries))
            layoutJson = JSON.stringify(next);

    }

    function entryLabel(entry) {
        if (entry.type === "separator")
            return i18n("Separator");

        if (entry.type === "custom")
            return entry.name || i18n("New entry");

        return actions.action(entry.id).text;
    }

    function entryKind(entry) {
        if (entry.type === "builtin")
            return i18n("Built-in");

        return entry.type === "custom" ? i18n("Custom") : i18n("Separator");
    }

    function updateEntry(id, property, value) {
        const next = entries.map((entry) => {
            return Object.assign({
            }, entry);
        });
        const entry = next.find((item) => {
            return item.id === id;
        });
        if (entry) {
            entry[property] = value;
            layoutJson = JSON.stringify(next);
        }
    }

    function addEntry(type) {
        const next = entries.slice();
        const entry = {
            "type": type,
            "id": MenuLayout.newId(next, type),
            "visible": true
        };
        if (type === "custom") {
            entry.name = i18n("New entry");
            entry.command = "";
        }
        next.splice(selectedIndex >= 0 ? selectedIndex + 1 : next.length, 0, entry);
        layoutJson = JSON.stringify(next);
        selectedId = entry.id;
    }

    function moveSelected(direction) {
        const target = selectedIndex + direction;
        if (selectedIndex < 0 || target < 0 || target >= entries.length)
            return ;

        const next = entries.slice();
        const entry = next.splice(selectedIndex, 1)[0];
        next.splice(target, 0, entry);
        layoutJson = JSON.stringify(next);
    }

    function deleteSelected() {
        if (!selectedEntry || selectedEntry.type === "builtin")
            return ;

        const next = entries.slice();
        next.splice(selectedIndex, 1);
        layoutJson = JSON.stringify(next);
    }

    function defaultLayoutJson() {
        // Restoring the layout must not discard users' custom commands.
        const custom = entries.filter((entry) => {
            return entry.type === "custom";
        }).map((entry) => {
            return Object.assign({
            }, entry, {
                "visible": false
            });
        });
        return custom.length ? JSON.stringify(MenuLayout.defaultEntries().concat(custom)) : "";
    }

    function restoreDefaults() {
        layoutJson = defaultLayoutJson();
    }

    onEntriesChanged: {
        syncEntries();
        if (selectedIndex < 0)
            selectedId = entries.length ? entries[0].id : "";

    }
    Component.onCompleted: syncEntries()
    onSelectedIndexChanged: Qt.callLater(() => {
        if (list && selectedIndex >= 0)
            list.positionViewAtIndex(selectedIndex, ListView.Contain);

    })

    ListModel {
        id: editModel
    }

    MenuActions {
        id: actions
    }

    Kirigami.InlineMessage {
        Layout.fillWidth: true
        visible: !root.parsed.valid
        type: Kirigami.MessageType.Warning
        text: i18n("The saved menu layout is invalid. The default layout is shown.")
    }

    QQC2.Label {
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        text: i18n("Hide entries with the checkboxes. Built-in names follow your desktop language.") + " " + i18n("Drag the handles to reorder entries.")
    }

    Flow {
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing

        QQC2.Button {
            text: i18n("Add custom entry")
            icon.name: "list-add"
            onClicked: root.addEntry("custom")
        }

        QQC2.Button {
            text: i18n("Add separator")
            icon.name: "insert-horizontal-rule"
            onClicked: root.addEntry("separator")
        }


        QQC2.ToolButton {
            text: i18n("Move up")
            display: QQC2.AbstractButton.IconOnly
            QQC2.ToolTip.text: text
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
            icon.name: "go-up"
            enabled: root.selectedIndex > 0
            onClicked: root.moveSelected(-1)
        }

        QQC2.ToolButton {
            text: i18n("Move down")
            display: QQC2.AbstractButton.IconOnly
            QQC2.ToolTip.text: text
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
            icon.name: "go-down"
            enabled: root.selectedIndex >= 0 && root.selectedIndex < root.entries.length - 1
            onClicked: root.moveSelected(1)
        }

        QQC2.ToolButton {
            text: i18n("Delete entry")
            display: QQC2.AbstractButton.IconOnly
            QQC2.ToolTip.text: text
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
            icon.name: "edit-delete"
            enabled: root.selectedEntry !== null && root.selectedEntry.type !== "builtin"
            onClicked: root.deleteSelected()
        }

    }

    QQC2.SplitView {
        id: panes

        objectName: "menuEditorPanes"
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.minimumHeight: Kirigami.Units.gridUnit * 18
        orientation: root.width < Kirigami.Units.gridUnit * 24 ? Qt.Vertical : Qt.Horizontal

        QQC2.Frame {
            objectName: "menuTreePane"
            QQC2.SplitView.minimumWidth: panes.orientation === Qt.Horizontal ? Kirigami.Units.gridUnit * 12 : 0
            QQC2.SplitView.preferredWidth: root.width * 0.55
            QQC2.SplitView.minimumHeight: Kirigami.Units.gridUnit * 8
            QQC2.SplitView.preferredHeight: Kirigami.Units.gridUnit * 12
            QQC2.SplitView.fillHeight: panes.orientation === Qt.Horizontal

            contentItem: QQC2.ScrollView {
                QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff

                ListView {
                    id: list

                    clip: true
                    model: editModel
                    currentIndex: root.selectedIndex
                    boundsBehavior: Flickable.StopAtBounds

                    delegate: Item {
                        id: wrapper

                        required property int index
                        required property string entryId
                        required property string entryType
                        required property bool entryVisible
                        required property string entryName
                        required property string entryCommand
                        readonly property var entry: ({
                            "id": entryId,
                            "type": entryType,
                            "visible": entryVisible,
                            "name": entryName,
                            "command": entryCommand
                        })

                        width: ListView.view.width
                        height: delegate.implicitHeight

                        MenuTreeDelegate {
                            id: delegate

                            width: wrapper.width
                            entry: wrapper.entry
                            modelIndex: wrapper.index
                            entryCount: editModel.count
                            view: list
                            labelText: root.entryLabel(wrapper.entry)
                            kindText: root.entryKind(wrapper.entry)
                            highlighted: root.selectedId === wrapper.entryId
                            onClicked: root.selectedId = wrapper.entryId
                            onVisibilityEdited: (shown) => {
                                root.selectedId = wrapper.entryId;
                                root.updateEntry(wrapper.entryId, "visible", shown);
                            }
                            onMoveRequested: (oldIndex, newIndex) => {
                                return editModel.move(oldIndex, newIndex, 1);
                            }
                            onReorderFinished: root.commitReorder()
                        }

                    }

                }

            }

        }

        QQC2.Frame {
            objectName: "menuPropertiesPane"
            QQC2.SplitView.minimumWidth: panes.orientation === Qt.Horizontal ? Kirigami.Units.gridUnit * 10 : 0
            QQC2.SplitView.fillWidth: true
            QQC2.SplitView.fillHeight: true

            contentItem: QQC2.ScrollView {
                id: propertiesScroll

                QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff

                ColumnLayout {
                    width: propertiesScroll.availableWidth
                    spacing: Kirigami.Units.largeSpacing

                    QQC2.Label {
                        Layout.fillWidth: true
                        text: root.selectedEntry ? root.entryLabel(root.selectedEntry) : i18n("Menu")
                        textFormat: Text.PlainText
                        wrapMode: Text.WordWrap
                        font.bold: true
                    }

                    QQC2.Label {
                        visible: root.selectedEntry !== null && root.selectedEntry.type !== "separator"
                        text: root.selectedEntry ? root.entryKind(root.selectedEntry) : ""
                        opacity: 0.7
                    }

                    Kirigami.Separator {
                        Layout.fillWidth: true
                        visible: root.selectedEntry !== null && root.selectedEntry.type === "separator"
                    }

                    Kirigami.FormLayout {
                        Layout.fillWidth: true
                        visible: root.selectedEntry !== null && root.selectedEntry.type !== "separator"

                        QQC2.TextField {
                            objectName: "menuEntryName"
                            readOnly: root.selectedEntry !== null && root.selectedEntry.type === "builtin"
                            Kirigami.FormData.label: i18n("Name:")
                            Layout.fillWidth: true
                            text: root.selectedEntry ? root.entryLabel(root.selectedEntry) : ""
                            onTextEdited: root.updateEntry(root.selectedId, "name", text)
                        }

                        Kirigami.ActionTextField {
                            objectName: "menuEntryCommand"
                            Kirigami.FormData.label: i18n("Command:")
                            Layout.fillWidth: true
                            text: root.selectedCommand
                            onTextEdited: root.setCommand(text)
                            rightActions: root.selectedCommandKey ? [resetCommand, clearCommand] : [clearCommand]

                            QQC2.Action {
                                id: resetCommand

                                icon.name: "edit-undo"
                                text: i18nc("@action:button", "Reset command")
                                enabled: root.selectedCommand !== String(root.commandDefaults[root.selectedCommandKey + "Default"] || "")
                                onTriggered: root.setCommand(String(root.commandDefaults[root.selectedCommandKey + "Default"] || ""))
                            }

                            QQC2.Action {
                                id: clearCommand

                                icon.name: "edit-clear"
                                text: i18nc("@action:button", "Clear command")
                                enabled: root.selectedCommand !== ""
                                onTriggered: root.setCommand("")
                            }

                        }

                    }

                }

            }

        }

    }

    QQC2.Button {
        text: i18n("Restore default layout")
        icon.name: "edit-undo"
        enabled: root.layoutJson !== root.defaultLayoutJson()
        onClicked: root.restoreDefaults()
    }

}

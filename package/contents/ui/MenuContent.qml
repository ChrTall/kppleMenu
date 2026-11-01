// SPDX-License-Identifier: GPL-2.0-or-later
// Configurable menu width and item height are inspired by 51n7/kMenu's
// ItemListView.qml and ItemListDelegate.qml (GPL-2.0-or-later):
// https://github.com/51n7/kMenu/blob/915bfc9d809fe30a6502dc9fd7f4f4d7f140d8d4/package/contents/ui/ItemListView.qml
// https://github.com/51n7/kMenu/blob/915bfc9d809fe30a6502dc9fd7f4f4d7f140d8d4/package/contents/ui/ItemListDelegate.qml
// Applied here to kppleMenu's own menu renderer with independent automatic sizing.
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami
import "code/menuLayout.js" as MenuLayout

FocusScope {
    id: root
    property string layoutJson: ""
    property var configuration: ({})
    property int shortcutLabelStyle: 0
    property bool automaticWidth: true
    property bool automaticHeight: true
    property int menuWidth: 240
    property int buttonHeight: 28
    readonly property var entries: MenuLayout.visibleEntries(MenuLayout.parse(layoutJson).entries)
    property int currentIndex: -1
    signal commandRequested(string command)

    implicitWidth: !automaticWidth ? Math.max(1, menuWidth) : Math.min(Kirigami.Units.gridUnit * 40,
        Math.max(Kirigami.Units.gridUnit * 12.6, entries.length ? column.implicitWidth
            : emptyLabel.implicitWidth + Kirigami.Units.gridUnit))
    implicitHeight: Math.min(Kirigami.Units.gridUnit * 30,
        Math.max(column.implicitHeight, emptyLabel.implicitHeight + Kirigami.Units.smallSpacing * 2))

    MenuActions { id: actions }
    PlasmaExtras.Highlight { id: delegateHighlight; visible: false }

    function commandFor(entry) {
        if (entry.type === "custom") {
            return entry.command;
        }
        const action = actions.action(entry.id);
        return action ? String(configuration[action.commandKey] || "") : "";
    }

    function labelFor(entry) {
        const action = entry.type === "builtin" ? actions.action(entry.id) : null;
        return action ? action.text : (entry.name || i18n("New entry"));
    }

    function shortcutFor(entry) {
        if (entry.type !== "builtin") {
            return "";
        }
        if (entry.id === "lock-screen") {
            return shortcutLabelStyle === 1 ? "Ctrl+Alt+Q" : "⌃⌘Q";
        }
        if (entry.id === "log-out") {
            return shortcutLabelStyle === 1 ? "Shift+Alt+Q" : "⇧⌘Q";
        }
        return "";
    }

    function activateEntry(entry) {
        const command = commandFor(entry);
        if (!entry.visible || entry.type === "separator" || !command.trim()) {
            return false;
        }
        commandRequested(command);
        return true;
    }

    function activateBuiltin(id) {
        const entry = entries.find(function(item) { return item.type === "builtin" && item.id === id; });
        return entry ? activateEntry(entry) : false;
    }

    function clearSelection() {
        currentIndex = -1;
        if (delegateHighlight) {
            if (delegateHighlight.parent && delegateHighlight.parent !== root) {
                delegateHighlight.parent.focus = false;
            }
            delegateHighlight.visible = false;
            delegateHighlight.parent = root;
        }
    }

    function moveSelection(direction) {
        const indexes = [];
        for (let i = 0; i < repeater.count; ++i) {
            if (repeater.itemAt(i).button.enabled) {
                indexes.push(i);
            }
        }
        if (!indexes.length) {
            return;
        }
        const position = indexes.indexOf(currentIndex);
        const next = position < 0 ? (direction > 0 ? 0 : indexes.length - 1)
            : (position + direction + indexes.length) % indexes.length;
        const row = repeater.itemAt(indexes[next]);
        row.button.forceActiveFocus(Qt.TabFocusReason);
        if (row.y < flick.contentY) {
            flick.contentY = row.y;
        } else if (row.y + row.height > flick.contentY + flick.height) {
            flick.contentY = row.y + row.height - flick.height;
        }
    }

    onEntriesChanged: clearSelection()
    onVisibleChanged: if (!visible) clearSelection()

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Up || event.key === Qt.Key_Down
            || event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
            const backwards = event.key === Qt.Key_Up || event.key === Qt.Key_Backtab
                || (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier));
            moveSelection(backwards ? -1 : 1);
            event.accepted = true;
        } else if (event.key === Qt.Key_Q && !event.isAutoRepeat) {
            const commandModifier = event.modifiers & (Qt.AltModifier | Qt.MetaModifier);
            const otherModifiers = event.modifiers & ~(Qt.AltModifier | Qt.MetaModifier);
            if (commandModifier && otherModifiers === Qt.ControlModifier) {
                event.accepted = activateBuiltin("lock-screen");
            } else if (commandModifier && otherModifiers === Qt.ShiftModifier) {
                event.accepted = activateBuiltin("log-out");
            }
        }
    }

    QQC2.ScrollView {
        anchors.fill: parent
        Keys.forwardTo: [root]
        QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff
        Flickable {
            id: flick
            Keys.forwardTo: [root]
            clip: true
            contentWidth: width
            contentHeight: column.implicitHeight
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: column
                width: flick.width
                spacing: 2
                Repeater {
                    id: repeater
                    model: root.entries
                    delegate: Item {
                        id: row
                        required property var modelData
                        required property int index
                        property alias button: commandButton
                        readonly property bool separator: modelData.type === "separator"
                        Layout.fillWidth: true
                        implicitWidth: separator ? 0 : commandButton.implicitWidth
                        implicitHeight: separator ? 11 : root.automaticHeight ? commandButton.implicitHeight
                            : Math.max(commandButton.implicitHeight, root.buttonHeight)

                        Rectangle {
                            visible: row.separator
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            height: 1
                            color: Kirigami.Theme.textColor
                            opacity: 0.2
                        }
                        ListDelegate {
                            id: commandButton
                            anchors.fill: parent
                            visible: !row.separator
                            enabled: !row.separator && root.commandFor(row.modelData).trim().length > 0
                            opacity: enabled ? 1 : 0.5
                            highlight: delegateHighlight
                            text: root.labelFor(row.modelData)
                            shortcutText: root.shortcutFor(row.modelData)
                            Keys.forwardTo: [root]
                            onActiveFocusChanged: if (activeFocus) root.currentIndex = row.index
                            onClicked: root.activateEntry(row.modelData)
                        }
                    }
                }
            }
        }
    }
    PlasmaComponents.Label {
        id: emptyLabel
        anchors.centerIn: parent
        visible: root.entries.length === 0
        text: i18n("No visible menu entries.")
    }
}

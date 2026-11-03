// SPDX-License-Identifier: GPL-2.0-or-later
// A dedicated visual menu configuration page is inspired by 51n7/kMenu's
// ConfigMenuJson.qml (GPL-2.0-or-later):
// https://github.com/51n7/kMenu/blob/915bfc9d809fe30a6502dc9fd7f4f4d7f140d8d4/package/contents/ui/config/ConfigMenuJson.qml
// Configuration bindings here retain kppleMenu's existing built-in command keys.
import QtQuick
import org.kde.kcmutils as KCM
import org.kde.plasma.plasmoid

KCM.SimpleKCM {
    id: root

    property alias cfg_menuLayout: editor.layoutJson
    property string cfg_aboutThisComputerSettings: ""
    property string cfg_systemPreferencesSettings: ""
    property string cfg_appStoreSettings: ""
    property string cfg_sleepSettings: ""
    property string cfg_restartSettings: ""
    property string cfg_shutDownSettings: ""
    property string cfg_lockScreenSettings: ""
    property string cfg_logOutSettings: ""
    property var commandDefaults: Plasmoid.configuration || ({
    })

    MenuEditor {
        id: editor

        width: parent.width
        height: Math.max(implicitHeight, root.availableHeight)
        builtinCommands: ({
            "aboutThisComputerSettings": root.cfg_aboutThisComputerSettings,
            "systemPreferencesSettings": root.cfg_systemPreferencesSettings,
            "appStoreSettings": root.cfg_appStoreSettings,
            "sleepSettings": root.cfg_sleepSettings,
            "restartSettings": root.cfg_restartSettings,
            "shutDownSettings": root.cfg_shutDownSettings,
            "lockScreenSettings": root.cfg_lockScreenSettings,
            "logOutSettings": root.cfg_logOutSettings
        })
        commandDefaults: root.commandDefaults
        onBuiltinCommandEdited: (key, command) => {
            return root["cfg_" + key] = command;
        }
    }

}

// SPDX-License-Identifier: GPL-2.0-or-later
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

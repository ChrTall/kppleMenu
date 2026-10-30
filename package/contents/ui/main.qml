/*
 *  SPDX-FileCopyrightText: 2020 Kpple <info.kpple@gmail.com>
 *  SPDX-FileCopyrightText: 2024 Christian Tallner <chrtall@gmx.de>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root
    toolTipSubText: i18n("Shortcuts for shutdown,reboot,logout, settings etc.")
    hideOnWindowDeactivate: true
    Plasmoid.icon: plasmoid.configuration.icon
    property bool fullRepHasFocus: false
    
    // define exec system ( call commands ) : by Uswitch applet! 
    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        property var callbacks: ({})
        onNewData: {
            var stdout = data["stdout"]

            if (callbacks[sourceName] !== undefined) {
                callbacks[sourceName](stdout);
            }

            exited(sourceName, stdout)
            disconnectSource(sourceName) // exec finished
        }

        function exec(cmd, onNewDataCallback) {
            // Hide Applet Window after a cmd was selected by the user.
            root.expanded = false
            if (onNewDataCallback !== undefined){
                callbacks[cmd] = onNewDataCallback
            }
            connectSource(cmd)
        }
        signal exited(string sourceName, string stdout)
    }

    onExpandedChanged: {
        root.fullRepHasFocus = expanded;
        if (!expanded && root.fullRepresentationItem) {
            root.fullRepresentationItem.clearSelection();
        }
    }

    fullRepresentation: MenuContent {
        layoutJson: Plasmoid.configuration.menuLayout
        configuration: Plasmoid.configuration
        shortcutLabelStyle: Plasmoid.configuration.shortcutLabelStyle
        focus: root.fullRepHasFocus
        Layout.preferredWidth: implicitWidth
        Layout.preferredHeight: implicitHeight
        onCommandRequested: command => executable.exec(command)
    }
}

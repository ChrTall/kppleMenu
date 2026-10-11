/*
 *  SPDX-FileCopyrightText: 2020 Kpple <info.kpple@gmail.com>
 *  SPDX-FileCopyrightText: 2024 Christian Tallner <chrtall@gmx.de>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.plasma.core as PlasmaCore
import org.kde.ksvg as KSvg
import org.kde.iconthemes as KIconThemes
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.config as KConfig
import org.kde.plasma.plasmoid

import "../code/tools.js" as Tools


KCM.SimpleKCM {
    id: root

    property string cfg_icon: Plasmoid.configuration.icon
    
    property alias cfg_showAdvancedMode: showAdvancedMode.checked
    property alias cfg_aboutThisComputerSettings: aboutThisComputerSettings.text
    property alias cfg_systemPreferencesSettings: systemPreferencesSettings.text
    property alias cfg_appStoreSettings: appStoreSettings.text
    property alias cfg_sleepSettings: sleepSettings.text
    property alias cfg_restartSettings: restartSettings.text
    property alias cfg_shutDownSettings: shutDownSettings.text
    property alias cfg_lockScreenSettings: lockScreenSettings.text
    property alias cfg_logOutSettings: logOutSettings.text


    Kirigami.FormLayout {
        /*
            *  Begin: code from plasma-desktop/applets/kickoff/contents/ui/ConfigGeneral.qml
            *  SPDX-FileCopyrightText: 2013 David Edmundson <davidedmundson@kde.org>
            *  SPDX-FileCopyrightText: 2021 Mikel Johnson <mikel5764@gmail.com>
            *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
            *  SPDX-FileCopyrightText: 2022 ivan tkachenko <me@ratijas.tk>
            *
            *  SPDX-License-Identifier: GPL-2.0-or-later
         */
        QQC2.Button {
            id: iconButton

            Kirigami.FormData.label: i18n("Icon:")

            implicitWidth: previewFrame.width + Kirigami.Units.smallSpacing * 2
            implicitHeight: previewFrame.height + Kirigami.Units.smallSpacing * 2
            hoverEnabled: true

            Accessible.name: i18nc("@action:button", "Change Kpple Menu's icon")
            Accessible.description: i18nc("@info:whatsthis", "Current icon is %1. Click to open menu to change the current icon or reset to the default icon.", root.cfg_icon)
            Accessible.role: Accessible.ButtonMenu

            QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
            QQC2.ToolTip.text: i18nc("@info:tooltip", "Icon name is \"%1\"", root.cfg_icon)
            QQC2.ToolTip.visible: iconButton.hovered && root.cfg_icon.length > 0

            KIconThemes.IconDialog {
                id: iconDialog
                onIconNameChanged: (iconName) => {
                    root.cfg_icon = iconName || Tools.defaultIconName;
                }
            }

            onPressed: iconMenu.opened ? iconMenu.close() : iconMenu.open()

            KSvg.FrameSvgItem {
                id: previewFrame
                anchors.centerIn: parent
                imagePath: Plasmoid.formFactor === PlasmaCore.Types.Vertical || Plasmoid.formFactor === PlasmaCore.Types.Horizontal
                    ? "widgets/panel-background" : "widgets/background"
                width: Kirigami.Units.iconSizes.large + fixedMargins.left + fixedMargins.right
                height: Kirigami.Units.iconSizes.large + fixedMargins.top + fixedMargins.bottom

                Kirigami.Icon {
                    anchors.centerIn: parent
                    width: Kirigami.Units.iconSizes.large
                    height: Kirigami.Units.iconSizes.large
                    source: Tools.iconOrDefault(Plasmoid.formFactor, root.cfg_icon)
                }
            }

            QQC2.Menu {
                id: iconMenu

                // Appear below the button
                y: parent.height

                QQC2.MenuItem {
                    text: i18nc("@item:inmenu Open icon chooser dialog", "Choose…")
                    icon.name: "document-open-folder"
                    Accessible.description: i18nc("@info:whatsthis", "Choose an icon for Application Launcher")
                    onClicked: iconDialog.open()
                }
                QQC2.MenuItem {
                    text: i18nc("@item:inmenu Reset icon to default", "Reset to default icon")
                    icon.name: "edit-clear"
                    enabled: root.cfg_icon !== Tools.defaultIconName
                    onClicked: root.cfg_icon = Tools.defaultIconName
                }
                QQC2.MenuItem {
                    text: i18nc("@action:inmenu", "Remove icon")
                    icon.name: "delete"
                    enabled: root.cfg_icon !== "" && Plasmoid.formFactor !== PlasmaCore.Types.Vertical
                    onClicked: root.cfg_icon = ""
                }
            }
        }
        /*
            End: code from plasma-desktop/applets/kickoff/contents/ui/ConfigGeneral.qml
        */
        
        QQC2.CheckBox {
            id: showAdvancedMode
            Kirigami.FormData.label: i18n("Advanced Settings:")
            text: i18n("Show advanced mode")
            checked: false
            enabled:true
        }

        Kirigami.ActionTextField {
            id: aboutThisComputerSettings
            Kirigami.FormData.label: i18n("About This Computer :")
            enabled: showAdvancedMode.checked
            // Kirigami lays out rightActions from right to left: reset, then clear.
            rightActions: [
                QQC2.Action {
                    icon.name: "edit-undo"
                    enabled: aboutThisComputerSettings.text !== Plasmoid.configuration.aboutThisComputerSettingsDefault
                    text: i18nc("@action:button", "Reset command")
                    onTriggered: root.cfg_aboutThisComputerSettings = Plasmoid.configuration.aboutThisComputerSettingsDefault
                },
                QQC2.Action {
                    icon.name: "edit-clear"
                    enabled: aboutThisComputerSettings.text !== ""
                    text: i18nc("@action:button", "Clear command")
                    onTriggered: aboutThisComputerSettings.clear()
                }
            ]
        }

        Kirigami.ActionTextField {
            id: systemPreferencesSettings
            Kirigami.FormData.label: i18n("System Preferences :")
            enabled: showAdvancedMode.checked
            rightActions: [
                QQC2.Action {
                    icon.name: "edit-undo"
                    enabled: systemPreferencesSettings.text !== Plasmoid.configuration.systemPreferencesSettingsDefault
                    text: i18nc("@action:button", "Reset command")
                    onTriggered: root.cfg_systemPreferencesSettings = Plasmoid.configuration.systemPreferencesSettingsDefault
                },
                QQC2.Action {
                    icon.name: "edit-clear"
                    enabled: systemPreferencesSettings.text !== ""
                    text: i18nc("@action:button", "Clear command")
                    onTriggered: systemPreferencesSettings.clear()
                }
            ]
        }

        Kirigami.ActionTextField {
            id: appStoreSettings
            Kirigami.FormData.label: i18n ("App Store :")
            enabled: showAdvancedMode.checked
            rightActions: [
                QQC2.Action {
                    icon.name: "edit-undo"
                    enabled: appStoreSettings.text !== Plasmoid.configuration.appStoreSettingsDefault
                    text: i18nc("@action:button", "Reset command")
                    onTriggered: root.cfg_appStoreSettings = Plasmoid.configuration.appStoreSettingsDefault
                },
                QQC2.Action {
                    icon.name: "edit-clear"
                    enabled: appStoreSettings.text !== ""
                    text: i18nc("@action:button", "Clear command")
                    onTriggered: appStoreSettings.clear()
                }
            ]
        }

        Kirigami.ActionTextField {
            id: sleepSettings
            Kirigami.FormData.label: i18n ("Sleep :")
            enabled: showAdvancedMode.checked
            rightActions: [
                QQC2.Action {
                    icon.name: "edit-undo"
                    enabled: sleepSettings.text !== Plasmoid.configuration.sleepSettingsDefault
                    text: i18nc("@action:button", "Reset command")
                    onTriggered: root.cfg_sleepSettings = Plasmoid.configuration.sleepSettingsDefault
                },
                QQC2.Action {
                    icon.name: "edit-clear"
                    enabled: sleepSettings.text !== ""
                    text: i18nc("@action:button", "Clear command")
                    onTriggered: sleepSettings.clear()
                }
            ]
        }

        Kirigami.ActionTextField {
            id: restartSettings
            Kirigami.FormData.label: i18n ("Restart :")
            enabled: showAdvancedMode.checked
            rightActions: [
                QQC2.Action {
                    icon.name: "edit-undo"
                    enabled: restartSettings.text !== Plasmoid.configuration.restartSettingsDefault
                    text: i18nc("@action:button", "Reset command")
                    onTriggered: root.cfg_restartSettings = Plasmoid.configuration.restartSettingsDefault
                },
                QQC2.Action {
                    icon.name: "edit-clear"
                    enabled: restartSettings.text !== ""
                    text: i18nc("@action:button", "Clear command")
                    onTriggered: restartSettings.clear()
                }
            ]
        }

        Kirigami.ActionTextField {
            id: shutDownSettings
            Kirigami.FormData.label: i18n ("Shut Down :")
            enabled: showAdvancedMode.checked
            rightActions: [
                QQC2.Action {
                    icon.name: "edit-undo"
                    enabled: shutDownSettings.text !== Plasmoid.configuration.shutDownSettingsDefault
                    text: i18nc("@action:button", "Reset command")
                    onTriggered: root.cfg_shutDownSettings = Plasmoid.configuration.shutDownSettingsDefault
                },
                QQC2.Action {
                    icon.name: "edit-clear"
                    enabled: shutDownSettings.text !== ""
                    text: i18nc("@action:button", "Clear command")
                    onTriggered: shutDownSettings.clear()
                }
            ]
        }

        Kirigami.ActionTextField {
            id: lockScreenSettings
            Kirigami.FormData.label: i18n ("Lock Screen :")
            enabled: showAdvancedMode.checked
            rightActions: [
                QQC2.Action {
                    icon.name: "edit-undo"
                    enabled: lockScreenSettings.text !== Plasmoid.configuration.lockScreenSettingsDefault
                    text: i18nc("@action:button", "Reset command")
                    onTriggered: root.cfg_lockScreenSettings = Plasmoid.configuration.lockScreenSettingsDefault
                },
                QQC2.Action {
                    icon.name: "edit-clear"
                    enabled: lockScreenSettings.text !== ""
                    text: i18nc("@action:button", "Clear command")
                    onTriggered: lockScreenSettings.clear()
                }
            ]
        }

        Kirigami.ActionTextField {
            id: logOutSettings
            Kirigami.FormData.label: i18n ("Log Out :")
            enabled: showAdvancedMode.checked
            rightActions: [
                QQC2.Action {
                    icon.name: "edit-undo"
                    enabled: logOutSettings.text !== Plasmoid.configuration.logOutSettingsDefault
                    text: i18nc("@action:button", "Reset command")
                    onTriggered: root.cfg_logOutSettings = Plasmoid.configuration.logOutSettingsDefault
                },
                QQC2.Action {
                    icon.name: "edit-clear"
                    enabled: logOutSettings.text !== ""
                    text: i18nc("@action:button", "Clear command")
                    onTriggered: logOutSettings.clear()
                }
            ]
        }
    }
}

 

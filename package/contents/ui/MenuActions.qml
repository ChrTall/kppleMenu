// SPDX-License-Identifier: GPL-2.0-or-later
import QtQuick

QtObject {
    readonly property var actions: [
        {id: "about", text: i18n("About This Computer"), commandKey: "aboutThisComputerSettings"},
        {id: "system-settings", text: i18n("System Settings…"), commandKey: "systemPreferencesSettings"},
        {id: "app-store", text: i18n("App Store…"), commandKey: "appStoreSettings"},
        {id: "sleep", text: i18n("Sleep"), commandKey: "sleepSettings"},
        {id: "restart", text: i18n("Restart…"), commandKey: "restartSettings"},
        {id: "shut-down", text: i18n("Shut Down…"), commandKey: "shutDownSettings"},
        {id: "lock-screen", text: i18n("Lock Screen"), commandKey: "lockScreenSettings"},
        {id: "log-out", text: i18n("Log Out…"), commandKey: "logOutSettings"}
    ]

    function action(id) {
        return actions.find(function(entry) { return entry.id === id; }) || null;
    }
}

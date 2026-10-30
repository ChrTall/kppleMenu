// SPDX-License-Identifier: GPL-2.0-or-later
import QtQuick
import QtTest
import "../package/contents/ui"
import "../package/contents/ui/config"
import "../package/contents/ui/code/menuLayout.js" as MenuLayout

Item {
    id: window
    width: 900
    height: 700

    // The production Plasma engine supplies these functions through KI18n.
    function i18n(message, argument) {
        return argument === undefined ? message : message.replace("%1", argument);
    }
    function i18nc(context, message) { return message; }

    MenuContent {
        id: menu
        width: implicitWidth
        height: implicitHeight
        configuration: ({
            aboutThisComputerSettings: "about-command",
            systemPreferencesSettings: "settings-command",
            appStoreSettings: "store-command",
            sleepSettings: "sleep-command",
            restartSettings: "restart-command",
            shutDownSettings: "shutdown-command",
            lockScreenSettings: "lock-command",
            logOutSettings: "logout-command"
        })
    }
    MenuEditor {
        id: editor
        x: 400
        width: 480
        height: 650
    }
    SignalSpy { id: commands; target: menu; signalName: "commandRequested" }
    ConfigMenu { id: configPage; width: 600; height: 600; visible: false }

    TestCase {
        name: "CustomizableMenu"
        when: windowShown

        function init() {
            failOnWarning(/.*/);
            menu.layoutJson = "";
            menu.shortcutLabelStyle = 0;
            editor.layoutJson = "";
            menu.clearSelection();
            menu.forceActiveFocus();
            commands.clear();
        }

        function test_default_layout() {
            compare(menu.entries.length, 11);
            compare(menu.entries[0].id, "about");
            compare(menu.entries[10].id, "log-out");
            compare(menu.commandFor(menu.entries[0]), "about-command");
            compare(menu.labelFor(menu.entries[2]), "System Settings…");
        }

        function test_invalid_layout_data() {
            return [
                {tag: "syntax", value: "{"},
                {tag: "object", value: "{}"},
                {tag: "unknown-builtin", value: '[{"type":"builtin","id":"missing"}]'},
                {tag: "duplicate", value: '[{"type":"builtin","id":"about"},{"type":"builtin","id":"about"}]'},
                {tag: "bad-visibility", value: '[{"type":"builtin","id":"about","visible":"false"}]'},
                {tag: "missing-command", value: '[{"type":"custom","id":"custom-one","name":"Test"}]'},
                {tag: "reserved-id", value: '[{"type":"custom","id":"lock-screen","name":"Test","command":"test"}]'}
            ];
        }
        function test_invalid_layout(data) {
            const result = MenuLayout.parse(data.value);
            verify(!result.valid);
            compare(result.entries.length, 11);
            menu.layoutJson = data.value;
            compare(menu.entries.length, 11);
        }

        function test_hide_all_and_restore() {
            const entries = MenuLayout.defaultEntries();
            entries.forEach(entry => entry.visible = false);
            menu.layoutJson = JSON.stringify(entries);
            compare(menu.entries.length, 0);
            verify(!menu.activateBuiltin("lock-screen"));
            keyClick(Qt.Key_Down);
            compare(menu.currentIndex, -1);
            editor.layoutJson = menu.layoutJson;
            editor.restoreDefaults();
            menu.layoutJson = editor.layoutJson;
            compare(menu.entries.length, 11);
            compare(menu.commandFor(menu.entries[0]), "about-command");
        }

        function test_separator_cleanup() {
            const entries = MenuLayout.defaultEntries();
            entries.forEach(entry => entry.visible = entry.type === "separator" || entry.id === "sleep" || entry.id === "lock-screen");
            const visible = MenuLayout.visibleEntries(entries);
            compare(visible.map(entry => entry.id).join(","), "sleep,separator-session,lock-screen");
        }

        function test_editor_custom_and_roundtrip() {
            editor.addEntry("custom");
            const id = editor.selectedId;
            editor.updateEntry(id, "name", "My <Terminal>");
            editor.updateEntry(id, "command", "terminal-command --option");
            editor.moveSelected(-1);
            compare(editor.entries[editor.selectedIndex].id, id);
            compare(editor.entries.filter(entry => entry.type === "builtin").length, 8);
            menu.layoutJson = editor.layoutJson;
            const entry = menu.entries.find(entry => entry.id === id);
            compare(menu.labelFor(entry), "My <Terminal>");
            verify(menu.activateEntry(entry));
            compare(commands.signalArguments[0][0], "terminal-command --option");
            editor.updateEntry(id, "visible", false);
            menu.layoutJson = editor.layoutJson;
            verify(!menu.entries.some(entry => entry.id === id));
            editor.updateEntry(id, "visible", true);
            menu.layoutJson = editor.layoutJson;
            verify(menu.entries.some(entry => entry.id === id));
            editor.deleteSelected();
            verify(!editor.entries.some(entry => entry.id === id));
        }

        function test_builtin_identity_and_visibility() {
            editor.selectedId = "lock-screen";
            editor.moveSelected(-1);
            editor.moveSelected(-1);
            const entry = editor.selectedEntry;
            menu.layoutJson = editor.layoutJson;
            compare(menu.labelFor(entry), "Lock Screen");
            compare(menu.shortcutFor(entry), "⌃⌘Q");
            menu.shortcutLabelStyle = 1;
            compare(menu.shortcutFor(entry), "Ctrl+Alt+Q");
            compare(menu.commandFor(entry), "lock-command");
            const count = editor.entries.length;
            editor.deleteSelected();
            compare(editor.entries.length, count);
            editor.updateEntry("lock-screen", "visible", false);
            menu.layoutJson = editor.layoutJson;
            verify(!menu.activateBuiltin("lock-screen"));
        }

        function test_shortcuts_data() {
            return [
                {tag: "lock-alt", modifiers: Qt.ControlModifier | Qt.AltModifier, command: "lock-command"},
                {tag: "lock-meta", modifiers: Qt.ControlModifier | Qt.MetaModifier, command: "lock-command"},
                {tag: "logout-alt", modifiers: Qt.ShiftModifier | Qt.AltModifier, command: "logout-command"},
                {tag: "logout-meta", modifiers: Qt.ShiftModifier | Qt.MetaModifier, command: "logout-command"},
                {tag: "ambiguous", modifiers: Qt.ControlModifier | Qt.ShiftModifier | Qt.AltModifier, command: ""}
            ];
        }
        function test_shortcuts(data) {
            keyClick(Qt.Key_Q, data.modifiers);
            compare(commands.count, data.command ? 1 : 0);
            if (data.command) compare(commands.signalArguments[0][0], data.command);
            editor.updateEntry("lock-screen", "visible", false);
            editor.updateEntry("log-out", "visible", false);
            menu.layoutJson = editor.layoutJson;
            commands.clear();
            menu.forceActiveFocus();
            keyClick(Qt.Key_Q, data.modifiers);
            compare(commands.count, 0);
        }

        function test_navigation() {
            keyClick(Qt.Key_Down);
            compare(menu.entries[menu.currentIndex].id, "about");
            keyClick(Qt.Key_Down);
            compare(menu.entries[menu.currentIndex].id, "system-settings");
            keyClick(Qt.Key_Tab);
            compare(menu.entries[menu.currentIndex].id, "app-store");
            keyClick(Qt.Key_Tab, Qt.ShiftModifier);
            compare(menu.entries[menu.currentIndex].id, "system-settings");
            keyClick(Qt.Key_Return);
            compare(commands.count, 1);
            compare(commands.signalArguments[0][0], "settings-command");
            menu.clearSelection();
            menu.forceActiveFocus();
            keyClick(Qt.Key_Up);
            compare(menu.entries[menu.currentIndex].id, "log-out");
        }

        function test_partial_layout_keeps_hidden_builtins() {
            const result = MenuLayout.parse('[{"type":"builtin","id":"sleep"}]');
            verify(result.valid);
            compare(result.entries.length, 8);
            compare(MenuLayout.visibleEntries(result.entries).length, 1);
            verify(result.entries.find(entry => entry.id === "lock-screen").visible === false);
        }

        function test_empty_custom_command() {
            editor.addEntry("custom");
            menu.layoutJson = editor.layoutJson;
            verify(!menu.activateEntry(editor.selectedEntry));
            compare(commands.count, 0);
        }

        function test_restore_preserves_custom_commands() {
            editor.addEntry("custom");
            const id = editor.selectedId;
            editor.updateEntry(id, "name", "My terminal");
            editor.updateEntry(id, "command", "terminal-command");
            editor.restoreDefaults();
            const entry = editor.entries.find(entry => entry.id === id);
            compare(entry.command, "terminal-command");
            verify(!entry.visible);
            menu.layoutJson = editor.layoutJson;
            compare(menu.entries.length, 11);
            editor.updateEntry(id, "visible", true);
            menu.layoutJson = editor.layoutJson;
            verify(menu.activateEntry(editor.selectedEntry));
            compare(commands.signalArguments[0][0], "terminal-command");
        }

        function descendants(item, predicate) {
            let result = [];
            for (const child of item.children) {
                if (predicate(child)) result.push(child);
                result = result.concat(descendants(child, predicate));
            }
            return result;
        }

        function test_editor_typing() {
            editor.addEntry("custom");
            wait(20);
            const fields = descendants(editor, item => typeof item.echoMode === "number");
            compare(fields.length, 2);
            const name = fields.find(item => item.text === "New entry");
            const command = fields.find(item => item.text === "");
            name.forceActiveFocus();
            keyClick(Qt.Key_A, Qt.ControlModifier);
            keyClick(Qt.Key_T);
            compare(editor.selectedEntry.name, "t");
            command.forceActiveFocus();
            keyClick(Qt.Key_X);
            compare(editor.selectedEntry.command, "x");
        }

        function test_config_page_save_and_reset() {
            const page = configPage;
            const editors = descendants(page, item => typeof item.layoutJson === "string");
            compare(editors.length, 1);
            const pageEditor = editors[0];
            pageEditor.addEntry("custom");
            const saved = page.cfg_menuLayout;
            verify(saved.length > 0);
            page.cfg_menuLayout = "";
            compare(pageEditor.entries.length, 11);
            page.cfg_menuLayout = saved;
            verify(pageEditor.entries.some(entry => entry.type === "custom"));
        }

        function test_builtin_command_editor() {
            const pageEditor = descendants(configPage, item => typeof item.layoutJson === "string")[0];
            configPage.cfg_restartSettings = "saved-restart";
            configPage.commandDefaults = {restartSettingsDefault: "default-restart"};
            pageEditor.selectedId = "restart";
            compare(pageEditor.selectedCommand, "saved-restart");
            pageEditor.setCommand("edited-restart");
            compare(configPage.cfg_restartSettings, "edited-restart");
            const field = descendants(pageEditor, item => item.rightActions !== undefined)[0];
            compare(field.rightActions.length, 2);
            field.rightActions[0].trigger();
            compare(configPage.cfg_restartSettings, "default-restart");
            field.rightActions[1].trigger();
            compare(configPage.cfg_restartSettings, "");
            pageEditor.setCommand("preserved-restart");
            pageEditor.restoreDefaults();
            compare(configPage.cfg_restartSettings, "preserved-restart");
        }

        function test_properties_pane_and_narrow_layout() {
            const originalWidth = editor.width;
            const tree = findChild(editor, "menuTreePane");
            const properties = findChild(editor, "menuPropertiesPane");
            const name = findChild(editor, "menuEntryName");
            const command = findChild(editor, "menuEntryCommand");
            try {
                editor.width = 640;
                editor.selectedId = "restart";
                wait(20);
                verify(properties.mapToItem(editor, 0, 0).x > tree.mapToItem(editor, 0, 0).x);
                verify(name.readOnly);
                compare(name.text, "Restart…");
                editor.addEntry("custom");
                editor.updateEntry(editor.selectedId, "name", "My app");
                editor.updateEntry(editor.selectedId, "command", "my-command");
                compare(name.text, "My app");
                verify(!name.readOnly);
                compare(command.text, "my-command");
                editor.width = 360;
                wait(20);
                verify(properties.mapToItem(editor, 0, 0).y > tree.mapToItem(editor, 0, 0).y);
            } finally {
                editor.width = originalWidth;
            }
        }

        function test_added_entry_is_visible_in_tree() {
            const entries = MenuLayout.defaultEntries();
            for (let i = 0; i < 25; ++i) {
                entries.push({id: "custom-scroll-" + i, type: "custom", name: "App " + i, command: "test", visible: true});
            }
            editor.layoutJson = JSON.stringify(entries);
            editor.selectedId = "custom-scroll-24";
            editor.addEntry("custom");
            wait(50);
            const handle = descendants(editor, item => typeof item.dragActive === "boolean"
                && typeof item.incrementalMoves === "boolean").find(item => item.index === editor.selectedIndex);
            verify(handle !== undefined);
            const position = handle.listItem.mapToItem(handle.listView, 0, 0);
            verify(position.y >= -0.5);
            verify(position.y + handle.listItem.height <= handle.listView.height + 0.5);
        }

        function test_mouse_drag_reorders() {
            wait(30);
            const handles = descendants(editor, item => typeof item.dragActive === "boolean"
                && typeof item.incrementalMoves === "boolean");
            const handle = handles.find(item => item.index === 0);
            const target = handles.find(item => item.index === 3);
            verify(handle !== undefined && target !== undefined);
            handle.listView.positionViewAtBeginning();
            wait(20);
            const start = handle.mapToItem(window, handle.width / 2, handle.height / 2);
            const end = target.mapToItem(window, target.width / 2, target.height / 2);
            mousePress(window, start.x, start.y);
            mouseMove(window, start.x, start.y + 15, 20);
            mouseMove(window, end.x, end.y, 20);
            mouseRelease(window, end.x, end.y);
            tryCompare(editor, "selectedIndex", 3);
            compare(editor.entries[3].id, "about");
            compare(editor.entries.length, 11);
            const saved = editor.layoutJson;
            editor.layoutJson = "";
            editor.layoutJson = saved;
            compare(editor.entries[3].id, "about");
        }

        function test_long_menu_scroll_and_centering() {
            const entries = [];
            for (let i = 0; i < 40; ++i) {
                entries.push({type: "custom", id: "custom-" + i, name: "Entry " + i, command: "test-command", visible: true});
            }
            menu.layoutJson = JSON.stringify(entries);
            wait(20);
            menu.forceActiveFocus();
            keyClick(Qt.Key_Up);
            compare(menu.entries[menu.currentIndex].id, "custom-39");
            const buttons = descendants(menu, item => typeof item.shortcutText === "string");
            const last = buttons.find(item => item.text === "Entry 39");
            verify(last.mapToItem(menu, 0, 0).y >= 0);
            verify(last.mapToItem(menu, 0, last.height).y <= menu.height + 0.5);
            const labels = descendants(last, item => item.text === "Entry 39");
            compare(labels.length, 1);
            compare(labels[0].verticalAlignment, Text.AlignVCenter);
            fuzzyCompare(labels[0].mapToItem(last, 0, labels[0].height / 2).y, last.height / 2, 0.5);
        }

        function test_hover_then_keyboard() {
            mouseMove(window, window.width - 1, 0);
            wait(20);
            const buttons = descendants(menu, item => typeof item.shortcutText === "string");
            const sleep = buttons.find(item => item.text === "Sleep");
            mouseMove(sleep, sleep.width / 2, sleep.height / 2);
            compare(menu.entries[menu.currentIndex].id, "sleep");
            keyClick(Qt.Key_Return);
            compare(commands.count, 1);
            compare(commands.signalArguments[0][0], "sleep-command");
            mouseMove(window, window.width - 1, 0);
        }
    }
}

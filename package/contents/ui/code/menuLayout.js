// SPDX-License-Identifier: GPL-2.0-or-later
.pragma library

const builtinIds = ["about", "system-settings", "app-store", "sleep", "restart", "shut-down", "lock-screen", "log-out"];

function defaultEntries() {
    return [
        {type: "builtin", id: "about", visible: true},
        {type: "separator", id: "separator-about", visible: true},
        {type: "builtin", id: "system-settings", visible: true},
        {type: "builtin", id: "app-store", visible: true},
        {type: "separator", id: "separator-apps", visible: true},
        {type: "builtin", id: "sleep", visible: true},
        {type: "builtin", id: "restart", visible: true},
        {type: "builtin", id: "shut-down", visible: true},
        {type: "separator", id: "separator-session", visible: true},
        {type: "builtin", id: "lock-screen", visible: true},
        {type: "builtin", id: "log-out", visible: true}
    ];
}

function parse(serialized) {
    if (!serialized || !serialized.trim()) {
        return {valid: true, entries: defaultEntries()};
    }
    try {
        const input = JSON.parse(serialized);
        if (!Array.isArray(input)) {
            throw new Error("Expected an array");
        }
        const ids = Object.create(null);
        const entries = input.map(function(entry) {
            if (!entry || typeof entry !== "object"
                || !["builtin", "custom", "separator"].includes(entry.type)
                || typeof entry.id !== "string" || !entry.id.trim()
                || Object.prototype.hasOwnProperty.call(ids, entry.id)
                || (entry.visible !== undefined && typeof entry.visible !== "boolean")) {
                throw new Error("Invalid or duplicate menu entry");
            }
            if ((entry.type === "builtin" && !builtinIds.includes(entry.id))
                || (entry.type !== "builtin" && builtinIds.includes(entry.id))) {
                throw new Error("Invalid built-in action ID");
            }
            ids[entry.id] = true;
            const result = {type: entry.type, id: entry.id, visible: entry.visible !== false};
            if (entry.type === "custom") {
                if (typeof entry.name !== "string" || typeof entry.command !== "string") {
                    throw new Error("Invalid custom entry");
                }
                result.name = entry.name;
                result.command = entry.command;
            }
            return result;
        });
        // Keep omitted built-ins available in the editor, without showing them.
        builtinIds.forEach(function(id) {
            if (!Object.prototype.hasOwnProperty.call(ids, id)) {
                entries.push({type: "builtin", id: id, visible: false});
            }
        });
        return {valid: true, entries: entries};
    } catch (error) {
        return {valid: false, entries: defaultEntries()};
    }
}

function visibleEntries(entries) {
    const result = [];
    entries.forEach(function(entry) {
        if (!entry.visible) {
            return;
        }
        // Suppress leading and consecutive separators after entries are hidden.
        if (entry.type === "separator" && (!result.length || result[result.length - 1].type === "separator")) {
            return;
        }
        result.push(entry);
    });
    if (result.length && result[result.length - 1].type === "separator") {
        result.pop();
    }
    return result;
}

function newId(entries, type) {
    let id;
    do {
        id = type + "-" + Date.now().toString(36) + "-" + Math.random().toString(36).slice(2);
    } while (entries.some(function(entry) { return entry.id === id; }));
    return id;
}

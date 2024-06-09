/*
 *  SPDX-FileCopyrightText: 2024 Christian Tallner <chrtall@gmx.de>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */
const defaultIconName = "start-here-kde-symbolic";

function iconOrDefault(formFactor, preferredIconName) {
    // Vertical panels must have an icon, at least a default one.
    return (formFactor === PlasmaCore.Types.Vertical && preferredIconName === "")
        ? defaultIconName : preferredIconName;
}
